#!/bin/bash
set -ueo pipefail

NAME="$1"
VaultName="$NAME"

Instances=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$NAME" | jq -c .Reservations[])
InstanceId=$(echo "$Instances" | jq -r .Instances[].InstanceId)
Region=$(echo "$Instances" | jq -r .Instances[].Placement.AvailabilityZone | sed 's/.$//')
AccountId=$(echo "$Instances" | jq -r .OwnerId)
ResourceArn=arn:aws:ec2:${Region}:${AccountId}:instance/${InstanceId}
IamRoleArn=arn:aws:iam::${AccountId}:role/service-role/AWSBackupDefaultServiceRole
CompleteWindowMinutes=1440 # 指定した時間以内に完了しなければキャンセル（Expire）
Lifecycle=DeleteAfterDays=1 # バックアップの削除

echo "-------------"
echo "Backup Params"
echo "-------------"
cat <(
echo "VaultName: $VaultName"
echo "IamRoleArn: $IamRoleArn"
echo "ResourceArn: $ResourceArn"
echo "CompleteWindowMinutes: $CompleteWindowMinutes"
echo "LifeCycle: $Lifecycle"
) | column -t

echo "Backup Start: $(date +%F:%T)"
Job=$(aws backup start-backup-job \
    --backup-vault-name "$VaultName" \
    --iam-role-arn "$IamRoleArn" \
    --resource-arn "$ResourceArn" \
    --complete-window-minutes "$CompleteWindowMinutes" \
    --lifecycle "$Lifecycle")
echo $Job | jq -r .BackupJobId
exit 0