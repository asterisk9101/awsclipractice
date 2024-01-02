#!/bin/bash
set -ueo pipefail

BackupJobId="$1"

aws backup describe-backup-job --backup-job-id "$BackupJobId" | jq .

exit 0
