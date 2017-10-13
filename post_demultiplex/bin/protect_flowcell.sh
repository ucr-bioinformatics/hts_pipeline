#!/bin/bash -l

if (( $# < 1 )); then
    echo "Usage: protect_flowcell.sh <FC_ID>"
    exit 1
fi

FC_ID="$1"

targetDir="${SHARED_GENOMICS}/${FC_ID}"
randomPass="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)"

htpasswd -b -c "${targetDir}/.htpasswd" "${FC_ID}" "$randomPass"

cat << EOF > "$targetDir/.htaccess"
AuthName "Please Log In"
AuthType Basic
Require valid-user
AuthUserFile /var/www/illumina_runs/${FC_ID}/.htpasswd
EOF

echo "Secured ${FC_ID} with password: ${randomPass}"

