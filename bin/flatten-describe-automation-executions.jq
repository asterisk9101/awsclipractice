#!/usr/bin/jq -crf
.AutomationExecutionMetadataList[] | {
    "1.AutomationExecutionId": .AutomationExecutionId,
    "2.DocumentName": .DocumentName,
    "3.AutomationExecutionStatus": .AutomationExecutionStatus,
    "4.ExecutionStartTime": .ExecutionStartTime[0:19],
    "5.ExecutionEndTime": .ExecutionEndTime[0:19]
}
