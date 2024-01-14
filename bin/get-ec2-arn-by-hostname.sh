#!/bin/bash
set -ueo pipefail

PROFILE="$1"
NameTag="$2"

# アカウントIDの取得
ACCOUNTID=$(aws sts get-caller-identity | jq -r .Account)

# インスタンスの検索
Instances=$(aws --profile "$PROFILE" ec2 describe-instances --filters "Name=tag:Name,Values=$NameTag")

# インスタンスIDの取得
InstanceId=$(echo "$Instances" | jq -r .Reservations[].Instances[].InstanceId)

if [ -z "$InstanceId" ]; then
    echo "インスタンスが見つかりません: $NameTag" >&2
    exit 1
fi

# リージョン情報の取得
REGION=$(echo "$Instances" | jq -r .Reservations[].Instances[].Placement.AvailabilityZone | sed 's/.$//')

# ARN の生成
ARN="arn:aws:ec2:$REGION:$ACCOUNTID:instance/$InstanceId"

echo "$ARN"

exit 0
