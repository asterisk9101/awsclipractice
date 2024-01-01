# データリストア手順

```bash
restore-find.sh vault
restore-ebs.sh recovery-point-id
ec2-find.sh
ebs-find.sh
ebs-attach instance vol-id
ebs-detach vol-id
```
