#!/bin/bash -l

DECRYPTED_PASS_FILE="$HTS_PIPELINE_HOME/passwords-decrypted.tsv"

# Decrypt encrypted password file
gpg --yes --output "$DECRYPTED_PASS_FILE" --decrypt "$HTS_PIPELINE_HOME/passwords.tsv.gpg" || echo "Failed to decrypt passwords"

# Skip first line and read all other lines
while read purpose user pass
do
    if [[ $purpose == "purpose" ]] || [[ -z "${purpose// }" ]] || [[ -z "${user// }" ]] || [[ -z "${pass// }" ]]; then
        # Invalid row - discard
        continue
    fi
    # echo "Purpose: $purpose, User: $user, Pass: $pass"
    if [[ "$purpose" == "db" ]]; then
        echo "Loaded DB credentials"
        export DB_USERNAME="$user"
        export DB_PASSWORD="$pass"
    fi
done < "$DECRYPTED_PASS_FILE"

