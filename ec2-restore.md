# リストア手順

```bash
# 現在のインスタンスのパラメータを保存
dump-ec2-params.sh $profile $hostname

# リカバリーポイントがあることを確認
arn=$(get-ec2-arn-by-hostname.sh $profile $hostname)
aws backup list-recovery-points-by-resource --resource-arn "$arn" | flatten-list-recoverypoint.jq | table.sh

# メタデータを出力して調整する

# インスタンスを削除する
delete-ec2.sh hostname

# リカバリーポイントを復旧する


```
