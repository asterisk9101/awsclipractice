#!/bin/bash
set -ueo pipefail

ACCOUNTID=$(aws sts get-caller-identity | jq -r .Account)

case "$1" in
vol-*)
    Volume=$(aws ec2 describe-volumes --filters "Name=volume-id,Values=$1")
    REGION=$(echo "$Volume" | jq -r .Volumes[].AvailabilityZone | sed 's/.$//')
    ARN="arn:aws:ec2:$REGION:$ACCOUNTID:volume/$1"
    ;;
i-*)
    Instance=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$1")
    REGION=$(echo "$Instance" | jq -r .Reservations[].Instances[].Placement.AvailabilityZone | sed 's/.$//')
    ARN="arn:aws:ec2:$REGION:$ACCOUNTID:instance/$1"
    ;;
*)
    echo "不明なリソースIDです: $1" >&2
    exit 1
    ;;
esac

echo $ARN
