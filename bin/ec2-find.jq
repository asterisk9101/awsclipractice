#!/usr/bin/jq -rf
.Reservations[].Instances[] | {
    "1.instance-id":      .InstanceId,
    "2.state":            .State.Name,
    "3.instance-type":    .InstanceType,
    "4.launch-time":      .LaunchTime,
    "5.platform-detail":  .PlatformDetails,
    "6.availability-zone":.Placement.AvailabilityZone,
    "7.Tags":            (.Tags | sort_by(.Key) | reduce .[] as $n (""; . + $n.Key + "=" + $n.Value + ";"))
}
