#!/bin/bash
###############################################################################
# ターゲットの EC2 インスタンスをバックアップする
###############################################################################
set -euo pipefail

# 関数定義
function format(){
    # info または error から呼び出し
    echo "$(date '+%F %T') $(basename "$0") $PROFILE $NameTag $1 $2"
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
NameTag="$2"
info "PROFILE=$PROFILE"
info "TagName=$NameTag"

# インスタンスの検索
Instances=$(aws --profile "$PROFILE" ec2 describe-instances --filters "Name=tag:Name,Values=$NameTag")

# インスタンスIDの取得
InstanceId=$(echo "$Instances" | jq -r .Reservations[].Instances[].InstanceId)

if [ -z "$InstanceId" ]; then error "インスタンスが見つかりません： $NameTag"; fi
if [ "$(echo "$InstanceId" | wc -l)" -gt 1 ]; then error "インスタンスが複数見つかりました: $InstanceId"; fi

info "InstanceID=$InstanceId"

Instance="$Instances"

# バックアップパラメータの設定
VaultName="$NameTag"
Region=$(echo "$Instance" | jq -r .Reservations[].Instances[].Placement.AvailabilityZone | sed 's/.$//')
AccountId=$(aws --profile "$PROFILE" sts get-caller-identity | jq -r .Account)
ResourceArn="arn:aws:ec2:${Region}:${AccountId}:instance/${InstanceId}"
IamRoleArn="arn:aws:iam::${AccountId}:role/service-role/AWSBackupDefaultServiceRole"
CompleteWindowMinutes=1440 # 指定した時間以内に完了しなければキャンセル（Expire）
Lifecycle=DeleteAfterDays=1 # バックアップの削除
Tags=$(echo "$Instance" | jq -rc ".Reservations[].Instances[].Tags | sort_by(.Key) | from_entries")

info "VaultName=$VaultName"
info "Region=$Region"
info "AccountId=$AccountId"
info "ResourceArn=$ResourceArn"
info "IamRoleArn=$IamRoleArn"
info "CompleteWindowMinutes=$CompleteWindowMinutes"
info "Lifecycle=$Lifecycle"
info "Tags=$Tags"

info "バックアップジョブを作成します"
Job=$(aws --profile "$PROFILE" backup start-backup-job \
    --backup-vault-name "$VaultName" \
    --iam-role-arn "$IamRoleArn" \
    --resource-arn "$ResourceArn" \
    --complete-window-minutes "$CompleteWindowMinutes" \
    --lifecycle "$Lifecycle" \
    --recovery-point-tags "$Tags")
JobId="$(echo "$Job" | jq -r .BackupJobId)"
info "バックアップジョブを作成しました: $JobId"

# 待つ処理
BackupJob=$(aws --profile "$PROFILE" backup describe-backup-job --backup-job-id "$JobId")
State=$(echo "$BackupJob" | jq -r .State)
while IsRunning "$State"
do
    info "バックアップ開始まで待機"
    sleep $(("$RANDOM" % 3 + 10)) # API アクセス制限にかからないように少し分散する
    BackupJob=$(aws --profile "$PROFILE" backup describe-backup-job --backup-job-id "$JobId")
    State=$(echo "$BackupJob" | jq -r .State)
done

info "バックアップが開始されました"
echo "$BackupJob" | jq .
