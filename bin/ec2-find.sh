#!/bin/bash
set -ueo pipefail

Instances=$(aws ec2 describe-instances --filters "$@" | jq -c ".Reservations[]")
headers="tag:Name                       instance-id  state       instance-type launch-time platform-details"
select="(.Tags | from_entries | .Name),.InstanceId, .State.Name,.InstanceType,.LaunchTime,.PlatformDetails"
query=".Instances[] | [$select] | @tsv"
cat <(echo "$headers"; echo "$Instances" | jq -c -r "$query") | column -t

exit 0
