#!/bin/bash -l

DECRYPTED_PASS_FILE="$HTS_PIPELINE_HOME/passwords-decrypted.tsv"

# Decrypt encrypted password file
gpg --yes --output "$DECRYPTED_PASS_FILE" --decrypt $HTS_PIPELINE_HOME/passwords.tsv.gpg || echo "Failed to decrypt passwords"

# Skip first line and read all other lines
sed 1d $DECRYPTED_PASS_FILE | while read purpose user pass
do
    if [[ -z "${purpose// }" ]] || [[ -z "${user// }" ]] || [[ -z "${pass// }" ]]; then
        # Invalid row - discard
        continue
    fi
    # echo "Purpose: $purpose, User: $user, Pass: $pass"
    if [[ "$purpose" -eq "db" ]]; then
        echo "Loaded DB credentials"
        DB_USERNAME="$user"
        DB_PASSWORD="$pass"
    fi
done

