{
    "tag:Name":    (.Tags | from_entries | .Name),
    "volume-id":   .VolumeId,
    "state":       .State,
    "size":        .Size,
    "create-time": .CreateTime,
    "volume-type": .VolumeType
}