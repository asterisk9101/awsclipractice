{
    "1.tag:Name":    (.Tags | from_entries | .Name),
    "2.volume-id":   .VolumeId,
    "3.state":       .State,
    "4.size":        .Size,
    "5.create-time": .CreateTime,
    "6.volume-type": .VolumeType
}