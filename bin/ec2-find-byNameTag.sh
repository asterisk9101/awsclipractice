#!/bin/bash
set -ueo pipefail

aws ec2 describe-instances --filters "Name=tag:Name,Values=${1}" | jq -r ".Reservations[].Instances[].InstanceId"

exit 0
