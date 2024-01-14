# リストア手順

こんな感じに

```bash
profile=
hostname=

# インスタンスの一覧を取得する
aws ec2 describe-instances | flatten-describe-instances.jq | table.sh

# リストア対象のインスタンスIDを控える
InstanceId=

# 現在のインスタンスのパラメータを保存
dump-ec2-params.sh $profile $InstanceId

###############################################################################
# インスタンス削除の際に ENI が削除されないように変更
###############################################################################

# ENI のアタッチメントIDを取得
cat $InstanceId-eni.json | flatten-describe-network-interfaces.jq | table.sh

# 対象の ENI の ID を控える
AttachmentId=
NetworkInterfaceId=

Attachment="AttachmentId=$AttachmentId,DeleteOnTermination=false"
aws ec2 modify-network-interface-attribute --network-interface-id "$NetworkInterfaceId" --attachment "$Attachment"

# DeleteOnTermination が false になっていることを確認する
aws ec2 describe-network-interfaces --network-interface-ids "$NetworkInterfaceId" | flatten-describe-network-interfaces.jq | table.sh

###############################################################################
# インスタンス削除の前にリカバリーポイントがあることを確認する
###############################################################################
# リカバリーポイントがあることを確認
recoverypoints=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$hostname")
echo "$recoverypoints" | flatten-list-recovery-points.jq | table.sh

RecoveryPointArn=
#aws backup describe-recovery-point --backup-vault-name "$hostname" --recovery-point-arn "$RecoveryPointArn"

# リストア用メタデータを保管する
aws backup get-recovery-point-restore-metadata --backup-vault-name "$hostname" --recovery-point-arn "$RecoveryPointArn" | jq .RestoreMetadata > metadata.json
cat metadata.json | jq -r .NetworkInterfaces | jq > metadata-network.json

# ネットワークのメタデータを加工する
NetworkMetadata=$(cat metadata-network.json | jq -c ".[] | [{DeviceIndex,NetworkInterfaceId}]" | sed -e 's/"/\\\\"/g' -e 's/^/"NetworkInterfaces":"/' -e 's/$/",/')

# メタデータを合成する
InstanceMetadata=$(cat metadata.json | sed -e '/NetworkInterfaces/d; /SubnetId/d; /SecurityGroupIds/d; /CpuOptions/d')
echo "$InstanceMetadata" | sed -e "2i$NetworkMetadata" | jq > metadata-restore.json

###############################################################################
# インスタンスを削除する
###############################################################################
# 削除実行
aws ec2 terminate-instances --instance-ids "$InstanceId"

aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" | flatten-describe-instances.jq | table.sh

###############################################################################
# インスタンスを削除する
###############################################################################
# リカバリーポイントから復元する
restore-ec2.sh $profile $RecoveryPointArn metadata-restore.json

aws ec2 describe-instances | flatten-describe-instances.jq | table.sh

# 元のパラメータと比較する
diff -y i-hogehoge.json i-fugafuga.json

```
