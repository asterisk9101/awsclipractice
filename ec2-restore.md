# リストア手順

```bash
# instance id を確認
ec2-find.sh

# instance の情報を保存しておく
ec2-info.sh id > json # instance.json, ebs.json, eni.json

# instance 削除
ec2-terminate id

# リカバリーポイントを確認する
restore-find.sh vault
restore-info.sh recovery-point-id

# リストアする
restore-ec2.sh recovery-point-id

# リストアされた instance id を探す
ec2-list.sh "Name=launch-time,Values=$(date '+%F*')"

# パラメータを復元する
ec2-copy-param from-id to-id

# パラメータが復元されていることを確認する
ec2-info.sh id > json # instance.json, instance-ebs.json, instance-eni.json
```
