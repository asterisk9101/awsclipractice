#!/bin/bash
###############################################################################
# リカバリーポイントから EC2 インスタンスを復元する
###############################################################################
set -euo pipefail

# 関数定義
function format(){
    # info または error から呼び出し
    echo "$(date '+%F %T') $(basename "$0") $PROFILE $1 $2"
}

function info(){
    format "INFO" "$1"
}

function error(){
    format "ERROR" "$1" >&2
    exit 1
}

function IsRunning(){
    # バックアップジョブのステータス確認
    case "$1" in
    "CREATED" | "PENDING")
        return 0;;
    *)
        # RUNNING になったら次の処理を開始して良い？
        return 1;;
    esac
}

PROFILE="$1"
RecoveryPointArn="$2"
Metadata="$3"
info "PROFILE=$PROFILE"
info "RecoveryPointArn=$RecoveryPointArn"
info "Metadata=$Metadata"

# リストアパラメータの設定
Region=$(echo "$RecoveryPointArn" | sed 's/arn:aws:ec2://; s/:.*//')
AccountId=$(aws --profile "$PROFILE" sts get-caller-identity | jq -r .Account)
IamRoleArn="arn:aws:iam::${AccountId}:role/AWSBackupServiceRoleWithPassRole"

info "Region=$Region"
info "AccountId=$AccountId"
info "IamRoleArn=$IamRoleArn"

info "リストアジョブを作成します"
Job=$(aws --profile "$PROFILE" backup start-restore-job \
    --iam-role-arn "$IamRoleArn" \
    --recovery-point-arn "$RecoveryPointArn" \
    --metadata file://$Metadata \
    --copy-source-tags-to-restored-resource)

JobId="$(echo "$Job" | jq -r .RestoreJobId)"
info "リストアジョブを作成しました: $JobId"

# 待つ処理
RestoreJob=$(aws --profile "$PROFILE" backup describe-restore-job --restore-job-id "$JobId")
Status=$(echo "$RestoreJob" | jq -r .Status)
while IsRunning "$Status"
do
    info "リストアジョブ開始まで待機"
    sleep $(("$RANDOM" % 3 + 10)) # API アクセス制限にかからないように少し分散する
    RestoreJob=$(aws --profile "$PROFILE" backup describe-restore-job --restore-job-id "$JobId")
    Status=$(echo "$RestoreJob" | jq -r .Status)
done

info "リストアが開始されました"
echo "$RestoreJob" | jq .
