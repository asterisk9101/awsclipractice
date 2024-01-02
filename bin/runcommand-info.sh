#!/bin/bash
set -ueo pipefail
CommandId="$1"
aws ssm list-command-invocations --command-id "$CommandId" --detail | jq .
