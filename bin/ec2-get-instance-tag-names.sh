#!/bin/bash
set -ueo pipefail

echo "$1" | jq -r ".Reservations[].Instances[].Tags | from_entries | .Name"

exit 0
