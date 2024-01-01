#!/bin/bash
set -ueo pipefail
InstanceId="$1"
AutomationExecutionId=$(aws ssm \
    start-automation-execution \
    --document-name AWS-StartEC2Instance \
    --parameters "InstanceId=$InstanceId" \
    | jq -r .AutomationExecutionId)
echo "$AutomationExecutionId"
exit 0