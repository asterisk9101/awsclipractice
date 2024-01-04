#!/bin/bash
set -ueo pipefail

VolumeId="$1"
DeleteAfterDays="${2:-1}"

Resource=$(aws ec2 describe-volumes --filters "Name=volume-id,Values=$VolumeId")

AttachedInstanceId=$(echo "$Resource" | jq -r .Volumes[].Attachments[].InstanceId)

AttachedInstance=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$AttachedInstanceId")

AttachedInstanceName=$(echo "$AttachedInstance" | jq -r ".Reservations[].Instances[].Tags | from_entries | .Name")

VaultName="$AttachedInstanceName"

# Vault が無ければ作る
BackupVault=$(aws backup list-backup-vaults | jq -c '.BackupVaultList[] | select(.BackupVaultName == "'${VaultName}'")')

if [ -z $BackupVault ]; then
    echo -n "Create Backup Vault: "
    res=$(aws backup create-backup-vault --backup-vault-name "$VaultName")
    echo "$res" | jq -r -c ".BackupVaultArn"
fi

Region=$(echo "$Resource" | jq -r .Volumes[].AvailabilityZone | sed 's/.$//')
AccountId=$(echo "$AttachedInstance" | jq -r .Reservations[].OwnerId)
ResourceArn=arn:aws:ec2:${Region}:${AccountId}:volume/${VolumeId}
IamRoleArn=arn:aws:iam::${AccountId}:role/service-role/AWSBackupDefaultServiceRole
CompleteWindowMinutes=1440 # 指定した時間以内に完了しなければキャンセル（Expire）
Lifecycle=DeleteAfterDays=$DeleteAfterDays # バックアップの削除

Job=$(aws backup start-backup-job \
    --backup-vault-name "$VaultName" \
    --iam-role-arn "$IamRoleArn" \
    --resource-arn "$ResourceArn" \
    --complete-window-minutes "$CompleteWindowMinutes" \
    --lifecycle "$Lifecycle")

echo "$Job" | jq -r .BackupJobId

exit 0
