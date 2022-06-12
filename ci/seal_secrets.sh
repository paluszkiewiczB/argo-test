#!/bin/bash

set -e
set -o pipefail

# define list of secrets to seal
# secrets must be stored in directory 'secrets'
# sealed secret will be written to directory 'templates' in the same directory as secrets
# output file will have suffix '-sealed', e.g. 'passwords.yaml' -> 'passwords-sealed.yaml'
#
# required directory structure:
#
#  parent_directory
#    |- secrets
#    |   |- passwords.yaml          <- this is input
#    |- templates
#    |   |- passwords-sealed.yaml   <- this is output
#
function findSecrets() {
  while IFS= read -r -d '' template_key; do
    local secretsDir secretsParent file_name_no_extension output
    secretsDir="$(dirname "$template_key")"
    secretsParent="$(dirname "$secretsDir")"
    file_name_no_extension="$(basename "$template_key" ".yaml")"
    output="$secretsParent/templates/$file_name_no_extension-sealed.yaml"
    secrets[$template_key]="$output"
  done < <(find . -path "*/secrets/*.yaml")
}

function sealSecrets() {
  for template in "${!secrets[@]}"; do
    local output
    output="${secrets[$template]}"
    echo "Sealing file: '$template' and saving output to: '$output'"
    kubeseal --cert "$publicKeyLocation" --secret-file "$template" --sealed-secret-file "$output"
  done
}

function downloadSealingCert() {
  local publicKeyLocation
  publicKeyLocation="test-project/infra/sealed-secrets/cert/cert.pem"
  kubeseal --controller-name sealed-secrets --controller-namespace secrets --fetch-cert >"$publicKeyLocation"
  echo "Sealing key stored in: $publicKeyLocation"
}

function removeCreationTimestamp() {
  for secret in "${secrets[@]}"; do
    sed -i '/creationTimestamp: null/d' "$secret"
  done
}

declare -A secrets
findSecrets

if [ ${#secrets[@]} -eq 0 ]; then
  echo "No secrets to seal, finishing"
  exit 0
fi

downloadSealingCert
sealSecrets
removeCreationTimestamp

git add "${secrets[@]}"
git commit -m "[CI] seal secrets"
