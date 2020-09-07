#!/bin/bash

grep "GameId game=\"CK2HIP\".*order=\"\"" titles.xml | while read -r LINE ; do
  TITLE_ID=$(echo ${LINE} | awk -F\> '{print $2}' | awk -F\< '{print $1}')
  ORDER=$(grep "^${TITLE_ID}=" orders.txt | awk -F= '{print $2}')

  echo ${TITLE_ID}=${ORDER}
  sed -i 's/order=\"\">'${TITLE_ID}'/order=\"'${ORDER}'\">'${TITLE_ID}'/g' titles.xml
done
