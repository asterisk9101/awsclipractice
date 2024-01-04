#!/usr/bin/jq -rf
.Volumes[] | {
    "1.volume-id":   .VolumeId,
    "2.state":       .State,
    "3.size":        .Size,
    "4.create-time": .CreateTime[0:19],
    "5.volume-type": .VolumeType,
    "6.volume-type": .AvailabilityZone,
    "7.Encrypted": .Encrypted
}