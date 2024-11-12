# File: scripts/backup.ps1 (PowerShell script for Windows)
param(
    [string]$BackupDir = "C:\mongodb_backups",
    [int]$RetentionDays = 7,
    [string]$MongosHost = "localhost",
    [string]$MongosPort = "27117"
)

# Create timestamp for backup folder
$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupPath = Join-Path $BackupDir $Date

# Ensure backup directory exists
New-Item -ItemType Directory -Force -Path $BackupPath | Out-Null

# Function to perform backup
function Backup-MongoDB {
    Write-Host "Starting backup at $(Get-Date)"
    
    try {
        # Run mongodump
        mongodump --host $MongosHost --port $MongosPort --out $BackupPath
        
        if ($LASTEXITCODE -eq 0) {
            # Compress the backup
            Compress-Archive -Path $BackupPath -DestinationPath "$BackupDir\$Date.zip" -Force
            
            # Remove the uncompressed backup directory
            Remove-Item -Path $BackupPath -Recurse -Force
            
            Write-Host "Backup completed successfully at $(Get-Date)"
            return $true
        } else {
            Write-Host "Backup failed with exit code $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Host "Error during backup: $_"
        return $false
    }
}

# Function to clean up old backups
function Remove-OldBackups {
    Write-Host "Cleaning up old backups..."
    
    $CutoffDate = (Get-Date).AddDays(-$RetentionDays)
    
    Get-ChildItem -Path $BackupDir -Filter "*.zip" | 
    Where-Object { $_.LastWriteTime -lt $CutoffDate } | 
    ForEach-Object {
        Write-Host "Removing old backup: $($_.Name)"
        Remove-Item $_.FullName -Force
    }
}

# Main execution
function Main {
    # Check if mongodump is available
    try {
        mongodump --version | Out-Null
    }
    catch {
        Write-Host "Error: mongodump is not available. Please ensure MongoDB Database Tools are installed and in your PATH."
        exit 1
    }

    # Create backup directory if it doesn't exist
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    }

    # Perform backup
    $BackupSuccess = Backup-MongoDB
    
    if ($BackupSuccess) {
        # Clean up old backups only if current backup was successful
        Remove-OldBackups
    }
}

# Run the main function
Main

# File: scripts/backup.sh (Bash script for Docker)
#!/bin/bash

# Configuration
BACKUP_DIR="/backup/mongodb"
BACKUP_RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
MONGOS_HOST="mongos1"
MONGOS_PORT="27017"
CONTAINER_NAME="mongos1"

# Create backup directory
mkdir -p "${BACKUP_DIR}/${DATE}"

# Backup function
backup_database() {
    echo "Starting backup at $(date)"
    
    docker exec ${CONTAINER_NAME} mongodump \
        --host ${MONGOS_HOST} \
        --port ${MONGOS_PORT} \
        --out "/backup/mongodb/${DATE}"
    
    if [ $? -eq 0 ]; then
        # Compress backup
        cd "${BACKUP_DIR}"
        tar -czf "${DATE}.tar.gz" "${DATE}"
        rm -rf "${DATE}"
        
        echo "Backup completed successfully at $(date)"
        return 0
    else
        echo "Backup failed"
        return 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    echo "Cleaning up old backups..."
    find "${BACKUP_DIR}" -type f -name "*.tar.gz" -mtime +${BACKUP_RETENTION_DAYS} -delete
}

# Main execution
main() {
    # Check if backup directory exists
    if [ ! -d "${BACKUP_DIR}" ]; then
        mkdir -p "${BACKUP_DIR}"
    fi
    
    # Perform backup
    backup_database
    
    # If backup was successful, clean up old backups
    if [ $? -eq 0 ]; then
        cleanup_old_backups
    fi
}

main "$@"