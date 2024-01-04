#!/usr/bin/jq -rf
.Reservations[].Instances[] | {
    "1.tag:Name":         (.Tags | from_entries | .Name),
    "2.instance-id":      .InstanceId,
    "3.state":            .State.Name,
    "4.instance-type":    .InstanceType,
    "5.launch-time":      .LaunchTime,
    "6.platform-detail":  .PlatformDetails,
    "7.availability-zone":.Placement.AvailabilityZone
}
