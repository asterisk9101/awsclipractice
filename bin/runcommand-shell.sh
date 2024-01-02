#!/bin/bash
set -ueo pipefail
InstanceId="$1"
command="$2"
workingDirectory="${3:-/}"
executionTimeout="${4:-600}"
CommandId=$(aws ssm \
    send-command \
    --instance-id="$InstanceId" \
    --document-name AWS-RunShellScript \
    --comment "$command" \
    --parameters "commands=$command,workingDirectory=$workingDirectory,executionTimeout=$executionTimeout" \
    | jq -r .Command.CommandId)
echo $CommandId
exit 0
