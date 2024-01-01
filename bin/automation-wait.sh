#!/bin/bash
set -ueo pipefail
AutomationExecutionId="$1"

function IsContinue(){
    case "$1" in
    "Pending")
        return 0;;
    "InProgress")
        return 0;;
    "Waiting")
        return 0;;
    *)
        return 1;;
    esac
}

AutomationExecutionMetadata=$(aws ssm describe-automation-executions --filters "Key=ExecutionId,Values=$AutomationExecutionId")
Status=$(echo "$AutomationExecutionMetadata" | jq -r .AutomationExecutionMetadataList[0].AutomationExecutionStatus)

while IsContinue "$Status";
do
    # タイムアウトは automation 自体にあるので考慮しない
    sleep 5
    AutomationExecutionMetadata=$(aws ssm describe-automation-executions --filters "Key=ExecutionId,Values=$AutomationExecutionId")
    Status=$(echo "$AutomationExecutionMetadata" | jq -r .AutomationExecutionMetadataList[].AutomationExecutionStatus)
done

echo "$AutomationExecutionMetadata" | jq
if [ "$Status" != "Success" ]; then
    exit 1
fi
exit 0
