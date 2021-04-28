#!/bin/bash
LOCATIONS_FILE="locations.xml"

CHARACTERS=$(cat "${LOCATIONS_FILE}" | \
    sed 's/^.*value=\"\([^"]*\).*/\1/g' | \
    sed 's/[ \ta-zA-Z0-9<=>\?$%@#()\_\!:;,.\"'"\'"'\/-]//g' | \
    sort | uniq |
    sed 's/\(.\)/\1\n/g' | \
    sort | uniq | \
    awk '{a=a s $0;s=""}END{print a}')

echo "${CHARACTERS}" | awk -v FS= '/^>/ {print; next} {for (i=0;i<=NF/16;i++) {for (j=1;j<=16;j++) printf "%s", $(i*16 +j); print ""}}'
