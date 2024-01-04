#!/bin/bash
###############################################################################
# 初期化処理
###############################################################################
set -eo pipefail

LIST=0
VaultName=""

while [ $# -ne 0 ]
do
    case "$1" in
    --list | -l)
        LIST=1
        ;;
    *)
        if [ -z "$VaultName" ]; then
            VaultName="$1"
        else
            echo "不正な引数です: $1" >&2
            exit 1
        fi
        ;;
    esac
    shift
done

if [ -z "$VaultName" ]; then
    echo "ボールト名を指定してください" >&2
    exit 1
fi

###############################################################################
# 主処理
###############################################################################
set -u
Points=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name "$VaultName")

###############################################################################
# 出力処理
###############################################################################
if [ "$LIST" -eq 0 ]; then
    echo "$Points" | jq .
else
    query="$(dirname $0)/$(basename -s .sh $0).jq"
    table=$(echo "$Points" | jq -rf "$query")

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
