#!/bin/bash
set -ueo pipefail
InstanceId="$1"

Instances=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" | jq -c ".Reservations[]")

InstanceId=$(echo "$Instances" | jq -r .Instances[].InstanceId)
InstanceCount=$(echo "$InstanceId" | wc -l)
if [ "$InstanceCount" -ne 1 ]; then
    echo "Error: Result Not Unique: $InstanceCount" >&2
    exit 1
fi

echo "EC2インスタンスの情報をファイルに出力します: ${InstanceId}.json"
echo "$Instances" | jq .Instances[] > "${InstanceId}.json"

echo "EC2インスタンスに紐づくEBSの情報をファイルに出力します: ${InstanceId}-ebs.json"
VolumeIds=$(echo "$Instances" | jq -r .Instances[].BlockDeviceMappings[].Ebs.VolumeId)
Volumes=$(aws ec2 describe-volumes --volume-ids "$VolumeIds")
echo $Volumes | jq . > "${InstanceId}-ebs.json"

echo "EC2インスタンスに紐づくENIの情報をファイルに出力します: ${InstanceId}-eni.json"
InterfaceIds=$(echo "$Instances" | jq -r .Instances[].NetworkInterfaces[].NetworkInterfaceId)
Interfaces=$(aws ec2 describe-network-interfaces --network-interface-ids "$InterfaceIds")
echo $Interfaces | jq . > "${InstanceId}-eni.json"

exit 0
