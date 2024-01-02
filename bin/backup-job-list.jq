#!/usr/bin/jq -rf
.BackupJobs[] | {
    "1.BackupJobId": .BackupJobId,
    "2.State": .State,
    "3.BackupVaultName": .BackupVaultName,
    "4.ResourceArn": (.ResourceArn | sub(".*:";"")),
    "5.StatusMessage": .StatusMessage,
    "6.ResourceType": .ResourceType,
    "7.CreationDate": (.CreationDate[0:19] | sub("T";" "))
}
