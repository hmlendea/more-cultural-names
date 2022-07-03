#!/bin/bash
source "scripts/common/paths.sh"

LANGUAGE_IDS="$(grep "<Id>" "${LANGUAGES_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"
LOCATIONS_FILE_LANGUAGE_IDS=$(grep "<Name language=" "${LOCATIONS_FILE}" | sed 's/^.*language=\"\([^\"]*\).*/\1/g' | sort | uniq)

# The results are just *potentially* redundant languages
for LANGUAGE_ID in ${LANGUAGE_IDS}; do
    ! grep -q "${LANGUAGE_ID}" <<< "${LOCATIONS_FILE_LANGUAGE_IDS}" && echo "${LANGUAGE_ID}"
done
