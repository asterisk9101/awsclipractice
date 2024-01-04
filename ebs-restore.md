# データリストア手順

`VaultName` は予め指定しておく

```bash
# インスタンスを特定する
InstanceNameTag=""

ec2-find.sh -l -n $InstanceNameTag
InstanceId=""
AZ=""

# アタッチされているボリュームの一覧を取得する
ebs-find.sh -l -i $InstanceId
VolumeId=""

# ボリュームIDからARNを作成する
VolumeArn=$(ARN.sh $VolumeId)
echo $VolumeArn

# リカバリーポイントの一覧を取得する
aws backup list-recovery-points-by-resource --resource-arn $VolumeArn
RecoveryPointArn=""

# リカバリーポイントのメタデータを作る
Metadata=$(aws backup get-recovery-point-restore-metadata --backup-vault-name $VaultName --recovery-point-arn $RecoveryPointArn)
ACCOUNTID=$(aws sts get-caller-identity | jq -r .Account)
volumeType=$()
volumeSize=$(echo "$Metadata" | jq -r .RestoreMetadata.volumeSize)
iops=$()
throughput=$()
IamRoleArn=arn:aws:iam::$ACCOUNTID:role/service-role/AWSBackupDefaultServiceRole
RestoreMetaData="volumeSize=$volumeSize,availabilityZone=$AZ"

RestoreJobId=$(aws backup start-restore-job --recovery-point-arn $RecoveryPointArn --metadata $RestoreMetaData --iam-role-arn $IamRoleArn | jq -r .RestoreJobId)
Result=$(aws backup describe-restore-job --restore-job-id "$RestoreJobId")

CreatedResourceArn=$(echo "$Result" | jq -r .CreatedResourceArn)
CreatedResourceId=$(echo "$CreatedResourceArn" | sed 's;.*/;;')

# タグをコピーする
Tags=$(aws ec2 describe-volumes --filters "Name=volume-id,Values=$VolumeId" | jq -c .Volumes[].Tags)
aws ec2 create-tags --resources "$CreatedResourceId" --tags "$Tags"

# 必要に応じて EC2を停止して既存のボリュームをデタッチする

# 復元した EBS をアタッチする

# 古いボリュームを削除する

# OSで認識できるか確認する

# リカバリーポイントを確認する
recoverypoint-list.sh $VaultName
restore-ebs.sh recovery-point-id
ec2-find.sh
ebs-find.sh
ebs-attach instance vol-id
ebs-detach vol-id
```
