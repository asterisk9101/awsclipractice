#!/bin/bash
set -ueo pipefail
CommandId="$1"

function IsContinue(){
    case "$1" in
    "Pending")
        return 0;;
    "InProgress")
        return 0;;
    "Delayed")
        return 0;;
    *)
        return 1;;
    esac
}

Status=$(aws ssm list-command-invocations \
    --command-id "$CommandId" \
    | jq -r .CommandInvocations[0].Status)

while IsContinue "$Status"
do
    sleep 1
    Status=$(aws ssm list-command-invocations \
        --command-id "$CommandId" \
        | jq -r .CommandInvocations[0].Status)
done

aws ssm list-command-invocations \
    --command-id "$CommandId" --details \
    | jq -r .CommandInvocations[].CommandPlugins[].Output
exit 0
