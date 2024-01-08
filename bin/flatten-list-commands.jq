#!/usr/bin/jq -crf
.Commands[] | {
    "1.CommandId":   .CommandId,
    "2.Comment":       .Comment,
    "3.Status":        .Status,
    "4.Commands":   (reduce .Parameters.commands[] as $c (""; . + $c + ";")),
    "5.InstanceIds": (reduce .InstanceIds[] as $i (""; . + $i + ";"))
}
