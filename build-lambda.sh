#!/usr/bin/env bash

set -e

declare -a folder_without_lambdapy
folderwithout_py_count=0
for d in lambdas/*/; do
  cd $d
  if [  -f lambda_handler.py ]; then
    if [ -f requirements.txt ]; then
       pip3 install --upgrade -qqq -r requirements.txt -t .
    fi
    if [ -f lambda.py ]; then
      python3 -m py_compile lambda.py
    fi
    if [ -f lambda_handler.py ]; then
      python3 -m py_compile lambda_handler.py
    fi
    zip -r9 lambda.zip * -x \*.pyc \*.zip \*__pycache__* --filesync
  else
    folder_without_lambdapy[$folderwithout_py_count]="$d"
    folderwithout_py_count=$((folderwithout_py_count + 1))
  fi
  cd -
done
if [ -n "$folder_without_lambdapy" ]; then
  echo "WARNING: lambda.py file(s) do not exist in the these folder(s):"
  echo ${folder_without_lambdapy[*]}
fi
