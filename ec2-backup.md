# EC2 のバックアップ手順

こんな感じになったら良いな

```bash
fmt="%Y%m%d_%H%M%S"
service-stop hostname
service-stop hostname
service-stop hostname

service-stop-wait

server-stop hostname
server-stop hostname
server-stop hostname

server-stop-wait

backup-ec2.sh hostname 2>&1 > $(date "$fmt")_hostnaame.log
backup-ec2.sh hostname 2>&1 > $(date "$fmt")_hostnaame.log
backup-ec2.sh hostname 2>&1 > $(date "$fmt")_hostnaame.log

backup-wait id

server-start hostname
server-start hostname
server-start hostname

server-start-wait

```
