#!/usr/bin/jq -crf
.Volumes[] | {
    "1.volume-id":   .VolumeId,
    "2.state":       .State,
    "3.size":        .Size,
    "4.create-time-JST": (.CreateTime[0:19] + "Z" | fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")),
    "5.volume-type": .VolumeType,
    "6.volume-type": .AvailabilityZone,
    "7.Encrypted":   .Encrypted,
    "8.Tags":        (.Tags | sort_by(.Key) | reduce .[] as $n (""; . + $n.Key + "=" + $n.Value + ";"))
}
