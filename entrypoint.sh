#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if necessary environment variables are set
if [ -z "$GRAFANA_URL" ]; then
  echo "Error: GRAFANA_URL is not set."
  exit 1
fi

if [ -z "$GRAFANA_TOKEN" ]; then
  echo "Error: GRAFANA_TOKEN is not set."
  exit 1
fi

if [ -z "$GCS_BUCKET_NAME" ]; then
  echo "Error: GCS_BUCKET_NAME is not set."
  exit 1
fi

# Check if SERVICE_ACCOUNT_KEY_JSON is set
if [ -z "$SERVICE_ACCOUNT_KEY_JSON" ]; then
  echo "Error: SERVICE_ACCOUNT_KEY_JSON is not set."
  exit 1
fi

echo "SERVICE_ACCOUNT_KEY_JSON length: ${#SERVICE_ACCOUNT_KEY_JSON}"
echo "SERVICE_ACCOUNT_KEY_JSON content:"
echo "$SERVICE_ACCOUNT_KEY_JSON"

# Decode the service account key JSON and write it to a file
echo "$SERVICE_ACCOUNT_KEY_JSON" > /tmp/service-account.json

# Update GOOGLE_APPLICATION_CREDENTIALS to point to the new file
export GOOGLE_APPLICATION_CREDENTIALS="/tmp/service-account.json"

# Set default values for optional environment variables
GRAFANA_BACKUP_OUTPUT_DIR=${GRAFANA_BACKUP_OUTPUT_DIR:-/app/_OUTPUT_}
VERIFY_SSL=${VERIFY_SSL:-false}
SEARCH_API_LIMIT=${SEARCH_API_LIMIT:-5000}
FOLDERS_AS_FILES=${FOLDERS_AS_FILES:-false}
SAVE_AS_FOLDER=${SAVE_AS_FOLDER:-true}

#Authenticate with GCP
if [[ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
  gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
  echo "DONEEEEEEEEEE"
else
  echo "Error: GCP credentials file not found at $GOOGLE_APPLICATION_CREDENTIALS"
  exit 1
fi
echo "token -------------> $GRAFANA_TOKEN"
# Create backup directory if it doesn't exist
mkdir -p "$GRAFANA_BACKUP_OUTPUT_DIR"

# Create config.json file
# Create config.json file
cat <<EOF > /app/config.json
{
  "grafana": {
    "url": "$GRAFANA_URL",
    "token": "$GRAFANA_TOKEN",
    "search_api_limit": $SEARCH_API_LIMIT,
    "verify_ssl": $VERIFY_SSL
  },
  "export": {
    "folders_as_files": $FOLDERS_AS_FILES,
    "save_as_folder": $SAVE_AS_FOLDER,
    "output": "$GRAFANA_BACKUP_OUTPUT_DIR"
  }
}
EOF

echo "{
  "grafana": {
    "url": "$GRAFANA_URL",
    "token": "$GRAFANA_TOKEN",
    "search_api_limit": $SEARCH_API_LIMIT,
    "verify_ssl": $VERIFY_SSL
  },
  "export": {
    "save_as_folder": $SAVE_AS_FOLDER,
  }
}
"

# Run the Grafana backup
grafana-backup save --config /app/config.json

# Upload backups to GCS
BACKUP_DATE=$(date +%F)
gsutil -m cp -r "$GRAFANA_BACKUP_OUTPUT_DIR/*" "gs://$GCS_BUCKET_NAME/grafana-backup/$BACKUP_DATE/"

# Optional: Clean up local backups
rm -rf "$GRAFANA_BACKUP_OUTPUT_DIR"/*

echo "Backup completed and uploaded to gs://$GCS_BUCKET_NAME/grafana-backup/$BACKUP_DATE/"

# Exit successfully
exit 0
