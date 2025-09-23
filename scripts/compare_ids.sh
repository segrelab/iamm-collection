#!/bin/bash
# Check whether IDs are preserved across metadata files

all_ids=$(tail -q -n +2 *.csv | cut -f1 -d, | sort | uniq)

exit_status=0

for file in $(ls *.csv); do
  foo=$(echo "${all_ids[@]}" | diff -u <(cut -f1 -d, $file | tail -n +2 | sort) -)
  if [ $? == 1 ]; then
    exit_status=1
    echo "File $file is missing the following IDs: $foo"
  fi
done

exit $exit_status