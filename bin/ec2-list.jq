{
    "1.tag:Name":         (.Tags | from_entries | .Name),
    "2.instance-id":      .InstanceId,
    "3.state":            .State.Name,
    "4.instance-type":    .InstanceType,
    "5.launch-time":      .LaunchTime,
    "6.platform-detail":  .PlatformDetails
}
