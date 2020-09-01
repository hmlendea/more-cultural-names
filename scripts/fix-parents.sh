#!/bin/bash

grep "GameId game=\"CK2HIP\" parent=\"\"" titles.xml | while read -r LINE ; do
  TITLE_ID=$(echo ${LINE} | awk -F\> '{print $2}' | awk -F\< '{print $1}')
  PARENT_ID=$(grep "^${TITLE_ID}=" parents.txt | awk -F= '{print $2}')

  [ -z "${PARENT_ID}" ] && continue

  echo ${TITLE_ID}=${PARENT_ID}
  sed -i 's/CK2HIP\" parent=\"\" \([^>]*\)>'${TITLE_ID}'</CK2HIP\" parent=\"'${PARENT_ID}'\" \1>'${TITLE_ID}'</g' titles.xml
done
