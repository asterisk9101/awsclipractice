#!/bin/bash
set -ueo pipefail

Resources=$(aws ec2 describe-instances --filters "$@")

table=$(echo "$Resources" | ec2-list.jq)

if [ -z "$table" ]; then
    echo "Resource Not Found"
    exit 1
fi

keys=$(echo "$table" | jq -s -r -c ".[0] | keys" | sed -e 's/\[/[./' -e 's/,/,./g')
cat <(
    echo "$table" | jq -s -r ".[0] | keys | @csv"
    echo "$table" | jq -r "$keys | @csv"
) | tr -d '"' | column -s , -t

exit 0
