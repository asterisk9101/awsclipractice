#!/usr/bin/jq -crf
.BackupJobs[] | {
    "1.BackupJobId": .BackupJobId,
    "2.BackupVaultName": .BackupVaultName,
    "3.RecoveryPointArn": .RecoveryPointArn,
    "4.CreationDateJST": (.CreationDate[0:19] + "Z" | fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")),
    "5.State": .State,
    "6.ResourceType": .ResourceType,
    "7.MessageCategory": .MessageCategory
}
