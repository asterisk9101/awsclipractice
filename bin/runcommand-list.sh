#!/bin/bash
set -ueo pipefail

DATE="${1:-24} hours ago"
InvokedAfter=$(date "+%FT%TZ" --utc -d "$DATE")
filters="key=InvokedAfter,value=$InvokedAfter"

Jobs=$(aws ssm list-commands --filters "$filters")

table=$(echo "$Jobs" | runcommand-list.jq)

if [ -z "$table" ]; then
    echo "Job Not Found"
    exit 1
fi

keys=$(echo "$table" | jq -s -r -c ".[0] | keys" | sed -e 's/\[/[./' -e 's/,/,./g')
cat <(
    echo "$table" | jq -s -r ".[0] | keys | @csv"
    echo "$table" | jq -r "$keys | @csv"
) | tr -d '"' | column -s , -t

exit 0