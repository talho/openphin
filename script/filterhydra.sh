#!/bin/bash
FAILED=0
FEATURES="\*\* \[out \:\: testmaster\.texashan\.org\] features"
HYDRA="\*\* \[out \:\: testmaster\.texashan\.org\] Hydra"
errors=()
count=0

while read line
do
  if [[ "$line" =~ 'failed steps' ]]; then
    FAILED=1
  fi
  if [[ "$line" =~ ^$FEATURES ]]; then
    if [ $FAILED = 1 ]; then
      EXISTS=0
      for item in `seq 0 $count`;
      do
        if [ "${errors[$item]}" = "$line" ]; then
          EXISTS=1
        fi
      done
      if [ $EXISTS = 0 ]; then
        count=$(($count+1))
        echo "$line"
        errors[$count]=$line
      fi
    fi
  fi
  if [[ "$line" =~ ^$HYDRA ]]; then
    FAILED=0
  fi
done
