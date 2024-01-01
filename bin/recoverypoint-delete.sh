#!/bin/bash
set -ueo pipefail

BackupVaultName="$1"
RecoveryPointArn="$2"

aws backup delete-recovery-point --backup-vault-name "$BackupVaultName" --recovery-point-arn "$RecoveryPointArn"

exit 0