#!/bin/bash
set -ueo pipefail

InstanceId="$1"
DeleteAfterDays="${2:-1}"

Instances=$(ec2-find-by-instance-id.sh "$InstanceId")
NAME=$(ec2-get-instance-tag-names.sh "$Instances")
VaultName="$NAME"

InstanceCount=$(echo "$InstanceId" | wc -l)
if [ "$InstanceCount" -eq 0 ]; then
    echo "InstanceId Not Found: $NAME"
    exit 1
fi
if [ "$InstanceCount" -ne 1 ]; then
    echo "InstanceId Not Uniq: $InstanceCount"
    exit 1
fi

# Vault が無ければ作る
BackupVault=$(aws backup list-backup-vaults | jq -c '.BackupVaultList[] | select(.BackupVaultName == "'${NAME}'")')
if [ -z "$BackupVault" ]; then
    echo "$BackupVault"
    exit 0
    echo -n "Create Backup Vault: "
    res=$(aws backup create-backup-vault --backup-vault-name "$NAME")
    echo "$res" | jq -r -c ".BackupVaultArn"
fi

Region=$(echo "$Instances" | jq -r .Reservations[].Instances[].Placement.AvailabilityZone | sed 's/.$//')
AccountId=$(echo "$Instances" | jq -r .Reservations[].OwnerId)
ResourceArn=arn:aws:ec2:${Region}:${AccountId}:instance/${InstanceId}
IamRoleArn=arn:aws:iam::${AccountId}:role/service-role/AWSBackupDefaultServiceRole
CompleteWindowMinutes=1440 # 指定した時間以内に完了しなければキャンセル（Expire）
Lifecycle=DeleteAfterDays=$DeleteAfterDays # バックアップの削除

Job=$(aws backup start-backup-job \
    --backup-vault-name "$VaultName" \
    --iam-role-arn "$IamRoleArn" \
    --resource-arn "$ResourceArn" \
    --complete-window-minutes "$CompleteWindowMinutes" \
    --lifecycle "$Lifecycle")
echo $Job | jq -r .BackupJobId
exit 0
