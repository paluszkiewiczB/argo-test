#!/bin/bash

set -e

chart_dirs=()
for chart_file in $(find ../ -path "*/Chart.yaml"); do
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
