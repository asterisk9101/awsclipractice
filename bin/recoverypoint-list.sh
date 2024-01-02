#!/bin/bash
set -ueo pipefail

NAME="${1:-Default}"

if [ "$NAME" == "Default" ]; then
    aws backup list-backup-vaults | jq -r '.BackupVaultList[] | select(.BackupVaultName != "Default") | .BackupVaultName'
    exit 0
fi

Points=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$NAME" | jq -c .RecoveryPoints[])
queryfile="$(dirname $0)/$(basename -s .sh $0).jq"
table=$(echo "$Points" | jq -c -r -f "$queryfile")

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
