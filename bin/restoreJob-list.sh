#!/bin/bash
set -ueo pipefail

DATE="${1:-yesterday}"

RestoreJobs=$(aws backup list-restore-jobs --by-created-after $(date "+%FT%TZ" --utc -d "$DATE"))

headers="RestoreJobId,Status,PercentDone,CreatedResourceArn,ResourceType,CreationDate"
select='.RestoreJobId,.Status,.PercentDone,.CreatedResourceArn,.ResourceType,(.CreationDate[0:19])'
query=".RestoreJobs[] | [$select] | @csv"

cat <(echo "$headers"; echo "$RestoreJobs" | jq -c -r "$query") | tr -d '"' | column -t -s ,
exit 0
