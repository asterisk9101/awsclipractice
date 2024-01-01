#!/bin/bash
set -ueo pipefail

DATE="${1:-yesterday}"

StartTimeAfter=$(date "+%FT%TZ" --utc -d "$DATE")
filters="Key=StartTimeAfter,Values=$StartTimeAfter"

AutomationExecutionMetadataList=$(aws ssm describe-automation-executions \
    --filters "$filters" \
    | jq -c .AutomationExecutionMetadataList[])

headers="AutomationExecutionId,DocumentName,Status,StartTime,EndTime,ExecutedBy"
select='.AutomationExecutionId,.DocumentName,.AutomationExecutionStatus,(.ExecutionStartTime[0:19] | sub("T";" ")),(.ExecutionEndTime[0:19] | sub("T";" ")),.ExecutedBy'
query=". | [$select] | @csv"

cat <(echo "$headers"; echo "$AutomationExecutionMetadataList" | jq -c -r "$query") | tr -d '"' | column -t -s ,
exit 0
