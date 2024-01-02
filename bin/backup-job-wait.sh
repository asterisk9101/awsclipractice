#!/bin/bash
set -ueo pipefail

BackupJobId="$1"

function IsContinue(){
    case "$1" in
    "CREATED")
        return 0;;
    "PENDING")
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

# バックアップが稼動（RUNNING）し始めたら終了

exit 0