#!/bin/bash
set -ueo pipefail

aws ec2 describe-instances --filters "Name=instance-id,Values=${1}" | jq -c .

exit 0
