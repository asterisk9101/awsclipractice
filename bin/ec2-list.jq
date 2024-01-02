{
    "tag:Name":         (.Tags | from_entries | .Name),
    "instance-id":      .InstanceId,
    "state":            .State.Name,
    "instance-type":    .InstanceType,
    "launch-time":      .LaunchTime,
    "platform-detail":  .PlatformDetails
}
