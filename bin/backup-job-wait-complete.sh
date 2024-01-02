#!/bin/bash
set -ueo pipefail

BackupJobId="$1"

function IsContinue(){
    case "$1" in
    "CREATED")
        return 0;;
    "PENDING")
        return 0;;
    "RUNNING")
        return 0;;
    *)
        return 1;;
    esac
}

BackupJob=$(aws backup describe-backup-job --backup-job-id "$BackupJobId" | jq .)
State=$(echo "$BackupJob" | jq -r .State)

while IsContinue "$State"
do
    sleep 60
    BackupJob=$(aws backup describe-backup-job --backup-job-id "$BackupJobId" | jq .)
    State=$(echo "$BackupJob" | jq -r .State)
done

echo "$BackupJob" | jq
if [ "$State" != "COMPLETED" ]; then
    exit 1
fi

exit 0
