#!/bin/bash
set -ueo pipefail

BackupVaultName="$1"
RecoveryPointArn="$2"

res=$(aws backup delete-recovery-point --backup-vault-name "$BackupVaultName" --recovery-point-arn "$RecoveryPointArn")

echo $res
exit 0