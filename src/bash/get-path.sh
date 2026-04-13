#!/usr/bin/env bash

paths=(
  "/usr/local/bin"
  "/usr/bin"
)
IFS=:
workdone=0
read -r -d '' -a paths_array <<<"${PATH}:"
for regex in "${paths[@]}"; do
  for p in "${paths_array[@]}"; do
    if echo "$p" | grep -qx --only-matching "$regex" && [[ $workdone -eq 0 ]]; then
      echo "$p"
      workdone=1
    fi
  done
done
