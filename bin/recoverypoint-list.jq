{
    "RecoveryPointArn": .RecoveryPointArn,
    "Status": .Status,
    "ResourceArn": (.ResourceArn | sub(".*:";"") ),
    "ResourceType": .ResourceType,
    "CreationDate": .CreationDate[0:19],
    "DeleteAt": .CalculatedLifecycle.DeleteAt[0:19]
}