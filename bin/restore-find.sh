#!/bin/bash
set -ueo pipefail

NAME="$1"

list=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$NAME")
header="BackupVaultName   ResourceType  RecoveryPointArn  CreationDate  DeleteAt"
select=".BackupVaultName,.ResourceType,.RecoveryPointArn,.CreationDate,.CalculatedLifecycle.DeleteAt"
query=".RecoveryPoints[] | [$select] | @tsv"
cat <(echo $header; echo $list | jq -r "$query") | column -t

exit 0