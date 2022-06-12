#!/bin/bash
# Script checks whether all Argo CRDS are deployed in the same, specified namespace
# Arg $1 is path to directory to scan
# Arg $2 is required namespace

set -e
set -o pipefail

toScan=$1
if [ -z "$toScan" ]; then
  toScan=$(pwd)
  echo "Directory to scan not specified, defaulting to $toScan"
fi

requiredNs=$2
if [ -z "$requiredNs" ]; then
  echo "Required namespace not specified, failing"
  exit 1
fi


function require_ns_for_argocd_manifests() {
  local testedFile
  testedFile=$1
  #FIXME test-project/infra/argocd/templates/applicationSet.yaml': yaml: line 14: did not find expected key
  isArgo=$(yq e "[.] | map(select(.apiVersion==\"argoproj.io/v1alpha1\")) | map(.metadata.namespace)" "$toScan")
  readarray -t results <<<"$isArgo"
  for actual in "${results[@]}"; do
    if [[ "$actual" != "- $requiredNs" ]]; then
      echo "In file $testedFile found namespace: $actual different than required: '$requiredNs'"
      return 1
    fi
  done
}

argo_files=$(grep -rnwl -e "apiVersion: argoproj.io/v1alpha1" --include "*.yaml" "$toScan")
while read -r argo_file; do
  require_ns_for_argocd_manifests "$argo_file" "argocd"
done <<<"$argo_files"
