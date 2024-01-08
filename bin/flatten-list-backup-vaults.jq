#!/usr/bin/jq -crf
.BackupVaultList[] | {
    "1.BackupVaultName":   .BackupVaultName,
    "2.EncryptionKeyArn":       .EncryptionKeyArn,
    "3.NumberOfRecoveryPoints":        .NumberOfRecoveryPoints,
    "4.Locked": .Locked
}
