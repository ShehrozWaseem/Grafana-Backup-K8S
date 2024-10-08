Here’s a `README.md` file template for your GitHub repository that explains the Grafana backup solution you have implemented, specifically focusing on how the backup is being stored in Google Cloud Storage (GCS):

### `README.md`

```markdown
# Grafana Backup to Google Cloud Storage (GCS)

This repository contains the configuration and resources to automate the daily backup of Grafana data and dashboards, storing the backups in Google Cloud Storage (GCS). The solution leverages Kubernetes and a cron job to run the backup process, using a Docker image of the Grafana Backup Tool.

## Overview

The goal of this project is to ensure regular backups of the Grafana instance running in your Kubernetes cluster. The backups include Grafana dashboards, data sources, and configurations, which are automatically stored in a specified Google Cloud Storage (GCS) bucket. This ensures that you can easily restore or migrate Grafana configurations in case of data loss or migrations.

## Key Features

- **Automated Daily Backups**: The setup uses a Kubernetes CronJob to schedule daily backups of Grafana at 4 AM.
- **Backup Storage in GCS**: All backups are securely stored in a Google Cloud Storage bucket.
- **Kubernetes Native**: The solution is deployed within Kubernetes, making use of namespaces, config maps, and secret management.
- **Token-Based Authentication**: Grafana authentication is managed via API tokens to ensure secure access during the backup process.

## Prerequisites

1. A running Kubernetes cluster.
2. Grafana instance deployed in the Kubernetes cluster.
3. A Google Cloud account and a GCS bucket for storing the backups.
4. A service account with sufficient permissions to write to GCS and a JSON key for the service account.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/grafana-backup-gcs.git
cd grafana-backup-gcs
```

### 2. Update Kubernetes Manifests

- **ConfigMap**: Update the `GRAFANA_URL`, `GRAFANA_TOKEN` with your Grafana instance information.
- **Google Cloud Storage**: Modify the GCS bucket name and path in the `ConfigMap` file.
  
### 3. Create a Google Cloud Service Account and Secret

1. Create a Google Cloud service account with `Storage Admin` permissions.
2. Download the service account key in JSON format.
3. Create a Kubernetes secret to store the GCS credentials:

    ```bash
    kubectl create secret generic gcs-credentials --from-file=credentials.json=/path/to/your/grafan_backup_key.json -n grafana-backup-tool
    ```

### 4. Deploy the Backup Tool

Deploy the Grafana Backup Tool to your Kubernetes cluster:

```bash
kubectl apply -f kubernetes/
```

### 5. Verify CronJob

You can verify that the cron job is created and scheduled properly:

```bash
kubectl get cronjob -n grafana-backup-tool
```

### 6. Test Backup

To test the backup process, you can manually run the backup job:

```bash
kubectl create job --from=cronjob/grafana-backup-tool manual-backup-job -n grafana-backup-tool
```

This should trigger a backup and store the files in the specified GCS bucket.

## Kubernetes Resources

- **Namespace**: A separate namespace (`grafana-backup-tool`) is used to organize resources.
- **ConfigMap**: Stores environment variables such as Grafana URL, authentication tokens, and GCS bucket details.
- **Secret**: Stores GCS credentials for authentication.
- **CronJob**: A Kubernetes cron job runs daily to perform the backup.

## Environment Variables

The backup tool relies on the following environment variables, managed via a Kubernetes ConfigMap:

- `GRAFANA_URL`: URL of the Grafana instance.
- `GRAFANA_TOKEN`: API token for Grafana.
- `GCS_BUCKET_NAME`: The name of the GCS bucket where backups are stored.
- `SERVICE_ACCOUNT_KEY_JSON`: Path to the service account JSON key for Google Cloud authentication.

## File Structure

```bash
├── kubernetes
│   ├── cronjob.yaml               # CronJob to schedule backups
│   ├── configmap.yaml             # ConfigMap for environment variables
│   ├── namespace.yaml             # Namespace for organizing resources
│   ├── secret.yaml                # Secret for storing GCS credentials
├── README.md                      # This file
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- The backup process uses the `https://github.com/ysde/grafana-backup-tool`.
```

### Key Points:
- The `README.md` explains the purpose of the project, prerequisites, setup instructions, Kubernetes resource details, and how to test and verify the solution.
- The structure of the project and environment variables are clearly outlined, ensuring that users can quickly understand how to use and customize the backup process.
