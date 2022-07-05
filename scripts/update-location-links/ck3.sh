#!/bin/bash
source "scripts/common/paths.sh"

function updateCk3LocationLinks() {
    local GAME_ID="${1}" && shift
    local OUTPUT_FILE="${REPO_DIR}/${GAME_ID}.txt"
    local VANILLA_LANDED_TITLES_FILE="${1}" && shift

    cp "${VANILLA_LANDED_TITLES_FILE}" "${OUTPUT_FILE}"
    sed -i 's/\r//g' "${OUTPUT_FILE}"
    sed -i 's/\t/    /g' "${OUTPUT_FILE}"

    for TITLE_ID in $(cat "${OUTPUT_FILE}" | \
                            grep "^ *[ekdcb]_" | \
                            sed 's/^ *\([ekdcb]_[^= ]*\).*/\1/g' | \
                            sort | uniq); do

        TITLE_NAME=$(tac "${@}" | \
                        grep "^ *[a-zA-Z]_" | \
                        grep "\b${TITLE_ID}:" | \
                        sed 's/ *\([a-zA-Z]_[^:]*\):[0-9] *\"\([^\"]*\)\".*/\2/g')

        sed -i 's/^\( *\)'"${TITLE_ID}"' *= *\([^\r\n]*\)$/\1# '"${TITLE_NAME}"'\n\1'"${TITLE_ID}"' = \2/g' "${OUTPUT_FILE}"
    done

    for CN in $(tac "${@}" | \
                    grep "^ *cn_" | grep -v "_adj:" | \
                    sed 's/ *\(cn_[^:]*\):[0-9] *\"\([^\"]*\)\"[^\"]*/\1=\2/g' | \
                    sed 's/ /@/g' | \
                    sort | uniq); do
        CN_ID=$(echo "${CN}" | awk -F= '{print $1}')
        CN_NAME=$(echo "${CN}" | awk -F= '{print $2}' | sed 's/@/ /g' | sed 's/^ *//g' | sed 's/ *$//g')

        sed -i 's/'"${CN_ID}"'\b/\"'"${CN_NAME}"'\"/g' "${OUTPUT_FILE}"
    done
}

updateCk3LocationLinks "CK3" "${CK3_VANILLA_LANDED_TITLES_FILE}" "${CK3_LOCALISATIONS_DIR}"/*.yml
