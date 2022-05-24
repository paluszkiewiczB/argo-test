#!/bin/bash

set -e

# define list of secrets to seal
# secrets must be stored in directory 'secrets'
# sealed secret will be written to directory 'templates' in the same directory as secrets
# output file will have suffix '-sealed', e.g. 'passwords.yaml' -> 'passwords-sealed.yaml'
declare -A secrets
function findSecrets() {
  for template_key in $(find . -path "*/secrets/*.yaml"); do
    secrets_dir="$(dirname "$template_key")"
    secrets_parent="$(dirname "$secrets_dir")"
    file_name_no_extension="$(basename "$template_key" ".yaml")"
    output="$secrets_parent/templates/$file_name_no_extension-sealed.yaml"
    echo "'$output'"
    secrets[$template_key]="$output"
  done
}

findSecrets

if [ ${#secrets[@]} -eq 0 ]; then
    echo "No secrets to seal, finishing"
    exit 0
fi

# download current sealing key
public_key_location="test-project/infra/sealed-secrets/cert/cert.pem"
kubeseal --controller-name sealed-secrets --controller-namespace secrets --fetch-cert >"$public_key_location"
echo "Sealing key stored in: $public_key_location"


for template in "${!secrets[@]}"; do
  output="${secrets[$template]}"
  echo "Sealing file: '$template' and saving output to: '$output'"
  kubeseal --cert "$public_key_location" --secret-file "$template" --sealed-secret-file "$output"
done
