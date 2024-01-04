#!/bin/bash

###############################################################################
# 初期化処理
###############################################################################
set -eo pipefail

LIST=0
InstanceId=""
NameTag=""

while [ $# -ne 0 ]
do
    case "$1" in
    --list | -l)
        LIST=1
        ;;
    --name | -n)
        shift
        NameTag="Name=tag:Name,Values=$1"
        ;;
    i-*)
        InstanceId="Name=instance-id,Values=$1"
        ;;
    *)
        echo "不正な引数です: $1" >&2
        exit 1
    esac
    shift
done

###############################################################################
# 主処理
###############################################################################
set -u

if [ -n "$InstanceId" ]; then
    Resources=$(aws ec2 describe-instances --filters "$InstanceId")
elif [ -n "$NameTag" ]; then
    Resources=$(aws ec2 describe-instances --filters "$NameTag")
else
    Resources=$(aws ec2 describe-instances)
fi


###############################################################################
# 出力処理
###############################################################################
if [ "$LIST" -eq 0 ]; then
    echo $Resources | jq .
else
    filter="$(dirname $0)/$(basename -s .sh $0).jq"
    table=$(echo "$Resources" | jq -rf "$filter")

    if [ -z "$table" ]; then
        echo "Resource Not Found"
        exit 1
    fi

    keys=$(echo "$table" | jq -s -r -c ".[0] | keys" | sed -e 's/\[/[./' -e 's/,/,./g')
    cat <(
        echo "$table" | jq -s -r ".[0] | keys | @csv"
        echo "$table" | jq -r "$keys | @csv"
    ) | tr -d '"' | column -s , -t
fi

exit 0