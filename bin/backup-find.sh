#!/bin/bash
set -ueo pipefail

FORMAT="${1:-%F}"

BackupJobs=$(aws backup list-backup-jobs --by-created-after $(date --utc +$FORMAT))

headers="BackupJobId,State,BackupVaultName,ResourceArn,StatusMessage,ResourceType,CreationDate"
select='.BackupJobId,.State,.BackupVaultName,(.ResourceArn | sub(".*:";"")),.StatusMessage,.ResourceType,(.CreationDate[0:19] | sub("T";" "))'
query=".BackupJobs[] | [$select] | @csv"

cat <(echo "$headers"; echo "$BackupJobs" | jq -c -r "$query") | tr -d '"' | column -t -s ,
exit 0
