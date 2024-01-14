#!/usr/bin/jq -crf
.NetworkInterfaces[] | {
    "1.AttachmentId":      .Attachment.AttachmentId,
    "2.DeleteOnTermination":            .Attachment.DeleteOnTermination,
    "3.AttachedInstanceId":    .Attachment.InstanceId,
    "4.AvailabilityZone":      .AvailabilityZone,
    "5.NetworkInterfaceId":  .NetworkInterfaceId,
    "6.VpcId":            .VpcId,
    "7.SubnetId":       .SubnetId
}
