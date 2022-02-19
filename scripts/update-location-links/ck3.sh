#!/bin/bash
source "scripts/common/paths.sh"

OUTPUT_FILE="${REPO_DIR}/3o.txt"

cp "${CK3_VANILLA_FILE}" "${OUTPUT_FILE}"
sed -i 's/\r//g' "${OUTPUT_FILE}"
sed -i 's/\t/    /g' "${OUTPUT_FILE}"

for TITLE_ID in $(cat "${OUTPUT_FILE}" | \
                        grep "^ *[ekdcb]_" | \
                        sed 's/^ *\([ekdcb]_[^= ]*\).*/\1/g' | \
                        sort | uniq); do

    TITLE_NAME=$(cat "${CK3_VANILLA_LOCALISATION_FILE}" | \
                    grep "^ *[a-zA-Z]_" | \
                    grep "\b${TITLE_ID}:" | \
                    sed 's/ *\([a-zA-Z]_[^:]*\):[0-9] *\"\([^\"]*\)\".*/\2/g')

    echo "${TITLE_ID}=${TITLE_NAME}"

    sed -i 's/^\( *\)'"${TITLE_ID}"' *= *\([^\r\n]*\)$/\1# '"${TITLE_NAME}"'\n\1'"${TITLE_ID}"' = \2/g' "${OUTPUT_FILE}"
done

for CN in $(cat "${CK3_VANILLA_CULTURAL_LOCALISATION_FILE}" | \
                        grep "^ *cn_" | grep -v "_adj:" | \
                        sed 's/ *\(cn_[^:]*\):[0-9] *\"\([^\"]*\)\"[^\"]*/\1=\2/g' | \
                        sed 's/ /@/g' | \
                        sort | uniq); do
    CN_ID=$(echo "${CN}" | awk -F= '{print $1}')
    CN_NAME=$(echo "${CN}" | awk -F= '{print $2}' | sed 's/@/ /g' | sed 's/^ *//g' | sed 's/ *$//g')

    echo "${CN_ID}=${CN_NAME}"

    sed -i 's/'"${CN_ID}"'\b/\"'"${CN_NAME}"'\"/g' "${OUTPUT_FILE}"
done
