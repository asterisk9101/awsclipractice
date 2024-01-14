#!/usr/bin/jq -crf
.AutomationExecutionMetadataList[] | {
    "1.AutomationExecutionId": .AutomationExecutionId,
    "2.DocumentName": .DocumentName,
    "3.AutomationExecutionStatus": .AutomationExecutionStatus,
    "4.ExecutionStartTimeJST": (.ExecutionStartTime[0:19] + "Z" | fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")),
    "5.ExecutionEndTimeJST": (.ExecutionEndTime[0:19] + "Z" | try (fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")) catch .)
}
