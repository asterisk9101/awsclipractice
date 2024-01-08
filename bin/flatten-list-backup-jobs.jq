#!/usr/bin/jq -crf
.BackupJobs[] | {
    "1.BackupJobId": .BackupJobId,
    "2.BackupVaultName": .BackupVaultName,
    "3.RecoveryPointArn": .RecoveryPointArn,
    "4.CreationDate": .CreationDate[0:19],
    "5.State": .State,
    "6.ResourceType": .ResourceType,
    "7.MessageCategory": .MessageCategory
}
