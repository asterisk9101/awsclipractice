#!/usr/bin/jq -crf

.RecoveryPoints[] | {
    "1.RecoveryPointArn": .RecoveryPointArn,
    "2.CreationDateJST": (.CreationDate[0:19] + "Z" | fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")),
    "3.Status": .Status,
    "4.BackupSizeBytes": .BackupSizeBytes,
    "5.BackupVaultName": .BackupVaultName,
    "6.ResourceName": .ResourceName
}
