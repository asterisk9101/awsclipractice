#!/bin/bash
set -ueo pipefail

NAME="$1:-Default"

if [ "$NAME" == "Default" ]; then
    aws backup list-backup-vaults | jq -r '.BackupVaultList[] | select(.BackupVaultName != "Default") | .BackupVaultName'
    exit 0
fi

list=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$NAME")
header="RecoveryPointArn   Status ResourceId                     ResourceType  CreationDate  DeleteAt"
select='.RecoveryPointArn,.Status,(.ResourceArn | sub(".*:";"") ),.ResourceType,.CreationDate[0:19],.CalculatedLifecycle.DeleteAt[0:19]'
query=".RecoveryPoints[] | [$select] | @tsv"
cat <(echo $header; echo $list | jq -r "$query") | column -t

exit 0
