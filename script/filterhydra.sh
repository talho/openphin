#!/bin/sh
FAILED=0
while read line
do
  if [[ "$line" =~ 'failed steps' ]]; then
    FAILED=1
  fi
  if [[ "$line" =~ ^feature ]]; then
    if [ $FAILED = 1]; then
      echo "$line"
    fi
  fi
  if [[ "$line" =~ ^Hyrda ]]; then
    FAILED=0
  fi
done
