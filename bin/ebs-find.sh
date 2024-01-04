#!/bin/bash
set -eo pipefail

###############################################################################
# 初期化処理
###############################################################################
LIST=0
VolumeId=""
InstanceId=""

while [ $# -ne 0 ]
do
    case "$1" in
    --list | -l)
        LIST=1
        ;;
    --by-attached-instance-id | -i)
        shift
        if [[ "$1" =~ i- ]]; then
            InstanceId="Name=attachment.instance-id,Values=$1"
        else
            echo "不正な引数です: $1" >&2
            exit 1
        fi
        ;;
    vol-*)
        VolumeId="Name=volume-id,Values=$1"
        ;;
    *)
        echo "不正な引数です: $1" >&2
        exit 1
        ;;
    esac
    shift
done

###############################################################################
# 主処理
###############################################################################
set -u

if [ -n "$VolumeId" ]; then
    Resources=$(aws ec2 describe-volumes --filters "$VolumeId")
elif [ -n "$InstanceId" ]; then
    Resources=$(aws ec2 describe-volumes --filters "$InstanceId")
else
    Resources=$(aws ec2 describe-volumes)
fi

###############################################################################
# 出力処理
###############################################################################
if [ "$LIST" -eq 0 ]; then
    echo "$Resources" | jq .
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
