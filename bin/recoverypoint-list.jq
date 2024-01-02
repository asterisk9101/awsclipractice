{
    "1.RecoveryPointArn": .RecoveryPointArn,
    "2.Status": .Status,
    "3.ResourceArn": (.ResourceArn | sub(".*:";"") ),
    "4.ResourceType": .ResourceType,
    "5.CreationDate": .CreationDate[0:19],
    "6.DeleteAt": .CalculatedLifecycle.DeleteAt[0:19]
}