#!/bin/bash
set -ueo pipefail

# 関数定義
function format(){
    # info または error から呼び出し
    echo "$(date '+%F %T') $(basename "$0") $PROFILE $NameTag $1 $2"
}

function info(){
    format "INFO" "$1"
}

function error(){
    format "ERROR" "$1" >&2
    exit 1
}

PROFILE="$1"
NameTag="$2"
info "PROFILE=$PROFILE"
info "TagName=$NameTag"

# インスタンスの検索
Instances=$(aws --profile "$PROFILE" ec2 describe-instances --filters "Name=tag:Name,Values=$NameTag")

# インスタンスIDの取得
InstanceId=$(echo "$Instances" | jq -r .Reservations[].Instances[].InstanceId)

if [ -z "$InstanceId" ]; then error "インスタンスが見つかりません： $NameTag"; fi
if [ "$(echo "$InstanceId" | wc -l)" -gt 1 ]; then error "インスタンスが複数見つかりました: $InstanceId"; fi

info "InstanceID=$InstanceId"

echo "EC2インスタンスの情報をファイルに出力します: ${InstanceId}.json"
echo "$Instances" | jq . > "${InstanceId}.json"

echo "EC2インスタンスに紐づくEBSの情報をファイルに出力します: ${InstanceId}-ebs.json"
VolumeIds=$(echo "$Instances" | jq -r .Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId | tr '\n' ' ')
Volumes=$(aws ec2 describe-volumes --volume-ids $VolumeIds)
echo $Volumes | jq . > "${InstanceId}-EBS.json"

echo "EC2インスタンスに紐づくENIの情報をファイルに出力します: ${InstanceId}-eni.json"
InterfaceIds=$(echo "$Instances" | jq -r .Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId | tr '\n' ' ')
Interfaces=$(aws ec2 describe-network-interfaces --network-interface-ids $InterfaceIds)
echo $Interfaces | jq . > "${InstanceId}-ENI.json"

exit 0
