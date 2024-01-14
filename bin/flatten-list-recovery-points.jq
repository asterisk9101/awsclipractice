#!/usr/bin/jq -crf
.RecoveryPoints[] | {
    "1.RecoveryPointArn": .RecoveryPointArn,
    "2.CreationDate": .CreationDate[0:19],
    "3.Status": .Status,
    "4.BackupSizeBytes": .BackupSizeBytes,
    "5.BackupVaultName": .BackupVaultName,
    "6.ResourceName": .ResourceName
}
