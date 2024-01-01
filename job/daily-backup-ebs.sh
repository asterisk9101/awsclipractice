#!/bin/bash
ec2=$(ec2-uniq-info.sh name)
volumes=$(echo ec2 | jq)
for ebs in volumes
    backup-ebs.sh ebs-id &
done
wait
