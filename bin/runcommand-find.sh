#!/bin/bash
###############################################################################
# 初期化処理
###############################################################################
set -eo pipefail

LIST=0
Hours=24
CommandId=""

while [ $# -ne 0 ]
do
    case "$1" in
    --list | -l)
        LIST=1
        ;;
    --after-hours | -a)
        shift
        if [[ "$1" =~ [0-9]+ ]]; then
            Hours="$1"
        else
            echo "不正な引数です: $1" >&2
            exit 1
        fi
        ;;
    *)
        if [ -z "$CommandId" ]; then
            CommandId="$1"
        else
            echo "不正な引数です: $1" >&2
            exit 1
        fi
        ;;
    esac
    shift
done

###############################################################################
# 主処理
###############################################################################
set -u

if [ -n "$CommandId" ]; then
    Jobs=$(aws ssm list-commands --command-id "$CommandId" --details)
else
    After="${Hours} hours ago"
    DATE=$(date "+%FT%TZ" --utc -d "$After")
    filters="key=InvokedAfter,value=$DATE"
    Jobs=$(aws ssm list-commands --filters "$filters")
fi

###############################################################################
# 出力処理
###############################################################################
if [ "$LIST" -eq 0 ]; then
    echo "$Jobs" | jq .
else
    query="$(dirname $0)/$(basename -s .sh $0).jq"
    table=$(echo "$Jobs" | jq -rf "$query")

    if [ -z "$table" ]; then
        echo "Job Not Found"
        exit 1
    fi

    keys=$(echo "$table" | jq -s -r -c ".[0] | keys" | sed -e 's/\[/[./' -e 's/,/,./g')
    cat <(
        echo "$table" | jq -s -r ".[0] | keys | @csv"
        echo "$table" | jq -r "$keys | @csv"
    ) | tr -d '"' | column -s , -t
fi

exit 0