# バックアップ手順

```bash
# 環境変数の設定
export AWS_PROFILE=$PROFILE

# インスタンス id を確認する
InstanceIds=$(ec2-find-by-name-tag.sh "$NAME")
echo "$InstanceIds"

# 複数のインスタンスがないことを確認する
InstanceId="$InstanceIds"
echo $InstanceId

# インスタンスのサービスを停止する
CommandId=$(runcommand-shell.sh "$InstanceId" svc-stop.sh)
echo "$CommandId"
runcommand-wait.sh "$CommandId"
runcommand-list.sh

# インスタンスを停止する
AutomationId=$(automation-stop-ec2.sh "$InstanceId")
echo "$AutomationId"
automation-wait.sh "$AutomationId"
automation-list.sh

# インスタンスが停止していることを確認する
ec2-list.sh "Name=instance-id,Values=$InstanceId"

# バックアップを実行（並列したい）
BackupJobId=$(backup-job-start-ec2.sh "$InstanceId")
echo "$BackupJobId"
backup-job-wait.sh "$BackupJobId"
backup-job-list.sh

# インスタンスを起動する
AutomationId=$(automation-start-ec2.sh "$InstanceId")
echo "$AutomationId"
automation-wait.sh "$AutomationId"
automation-list.sh

# インスタンスのサービスを起動する
CommandId=$(runcommand-shell.sh "$InstanceId" svc-start.sh)
echo "$CommandId"
runcommand-wait.sh "$CommandId"
runcommand-list.sh
```

```bash
recoverypoint-copy-start.sh 
recoverypoint-copy-start-parallel.sh
recoverypoint-copy-wait.sh
recoverypoint-copy-list.sh
recoverypoint-copy-info.sh
```
