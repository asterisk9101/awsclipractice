{
    "BackupJobId": .BackupJobId,
    "State": .State,
    "BackupVaultName": .BackupVaultName,
    "ResourceArn": (.ResourceArn | sub(".*:";"")),
    "StatusMessage": .StatusMessage,
    "ResourceType": .ResourceType,
    "CreationDate": (.CreationDate[0:19] | sub("T";" "))
}
