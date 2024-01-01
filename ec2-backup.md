# バックアップ手順

```bash
# 環境変数の設定
export AWS_PROFILE=tada

# instance id を確認する
ec2-find.sh "Name=tag:Name,Values=assumetest"
ssm-automation-stop-ec2.sh

# インスタンスのサービスを停止する
ssm-runcmd-shell.sh id svc-stop.sh
ssm-runcmd-find.sh
ssm-runcmd-wait.sh

# インスタンスを停止する
ssm-automation-ec2stop.sh id
ssm-automation-find.sh
ssm-automation-wait.sh id

# instance id が停止していることを確認する
ec2-find.sh Name=tag:Name,Values=hoge

# バックアップを実行（並列したい）
backup-ec2.sh i-hoge

# 待つ/結果の確認
backup-list-job.sh job-id

# インスタンスを起動する
ssm-automation-ec2start.sh

# インスタンスのサービスを起動する
ssm-runcmd-sh.sh id svc-start.sh
ssm-runcmd-wait.sh
```
