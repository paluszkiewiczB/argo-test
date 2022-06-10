#!/bin/bash
# Script checks whether all the Helm charts have lock file
# Arg $1 is path to directory to scan

set -e

toScan=$1
if [ -z "$toScan" ]; then
  toScan=$(pwd)
  echo "Directory to scan not specified, defaulting to $toScan"
fi

chart_dirs=()
for chart_file in $(find "$toScan" -path "*/Chart.yaml"); do
  chart_dirs+=("$(dirname "$chart_file")")
done

errors=()
for dir in "${chart_dirs[@]}"; do
  if [ ! -f "$dir/Chart.lock" ]; then
    errors+=("$dir")
  fi
done

if [ ${#errors[@]} -ne 0 ]; then
  echo "Some charts does not have lock file: ${errors[*]}"
  exit 1
fi
