#!/bin/bash
set -euo pipefail

# 標準入力がパイプ(0ではない)なら表敬式に整形して出力する
if [ ! -t 0 ]; then
    
    table=$(cat -)
    
    # パイプから何も入力されなかったら終了
    if [ -z "$table" ]; then exit 0; fi

    keys=$(echo "$table" | jq -s -r -c ".[0] | keys" | sed -e 's/\[/[./' -e 's/,/,./g')
    cat <(
        echo -ne '\e[1;34m' # blue bold
        echo "$table" | jq -s -r ".[0] | keys | @csv"
        echo -ne '\e[0;32m' # green regular
        echo "$table" | jq -r "$keys | @csv"
    ) | tr -d '"' | column -s , -t
    echo -ne '\e[0m' # color reset
fi

exit 0
