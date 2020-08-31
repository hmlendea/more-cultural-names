#!/bin/bash

while read LINE; do
  TITLE_ID=$(echo ${LINE} | awk -F= '{print $1}')
  ORDER=$(echo ${LINE} | awk -F= '{print $2}')

  echo ${TITLE_ID}=${ORDER}
  sed -i 's/order=\"\">'${TITLE_ID}'/order=\"'${ORDER}'\">'${TITLE_ID}'/g' titles.xml
done < orders.txt
