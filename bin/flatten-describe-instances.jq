#!/usr/bin/jq -crf
.Reservations[].Instances[] | {
    "1.instance-id":      .InstanceId,
    "2.state":            .State.Name,
    "3.instance-type":    .InstanceType,
    "4.launch-time-JST":      (.LaunchTime[0:19] + "Z" | fromdate | strftime("%F %X") | strptime("%F %X") | mktime + (60*60*9) | strftime("%F %X")),
    "5.platform-detail":  .PlatformDetails,
    "6.availability-zone":.Placement.AvailabilityZone,
    "7.Tags":            (.Tags | sort_by(.Key) | reduce .[] as $n (""; . + $n.Key + "=" + $n.Value + ";"))
}
