#!/bin/bash
set -ueo pipefail

DATE="${1:-yesterday}"

BackupJobs=$(aws backup list-backup-jobs --by-created-after $(date "+%FT%T" --utc -d "$DATE"))

headers="BackupJobId,State,BackupVaultName,ResourceArn,StatusMessage,ResourceType,CreationDate"
select='.BackupJobId,.State,.BackupVaultName,(.ResourceArn | sub(".*:";"")),.StatusMessage,.ResourceType,(.CreationDate[0:19] | sub("T";" "))'
query=".BackupJobs[] | [$select] | @csv"

cat <(echo "$headers"; echo "$BackupJobs" | jq -c -r "$query") | tr -d '"' | column -t -s ,
exit 0
