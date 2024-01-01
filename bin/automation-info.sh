#!/bin/bash
set -ueo pipefail
AutomationExecutionId="$1"
aws ssm describe-automation-executions --filters "Key=ExecutionId,Values=$AutomationExecutionId" | jq .
