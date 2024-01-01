#!/bin/bash
set -ueo pipefail
InstanceId="$1"
command="$2"
CommandId=$(aws ssm \
    send-command \
    --instance-id="$InstanceId" \
    --document-name AWS-RunShellScript \
    --parameters "commands=$command" \
    | jq -r .Command.CommandId)
echo $CommandId
exit 0
