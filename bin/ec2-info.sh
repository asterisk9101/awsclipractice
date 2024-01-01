#!/bin/bash
set -ueo pipefail
InstanceId="$1"

Instances=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" | jq -c ".Reservations[]")

InstanceId=$(echo "$Instances" | jq -r .Instances[].InstanceId)
InstanceCount=$(echo "$InstanceId" | wc -l)
if [ "$InstanceCount" -ne 1 ]; then
    echo "Error: Result Not Unique: $InstanceCount" >&2
    exit 1
fi

echo $Instances | jq .Instances[] > "${InstanceId}.json"

exit 0
