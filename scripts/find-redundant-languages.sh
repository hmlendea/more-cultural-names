#!/bin/bash
source "scripts/common/paths.sh"

LANGUAGE_IDS="$(grep "<Id>" "${LANGUAGES_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"
LOCATIONS_FILE_CONTENT=$(cat "${LOCATIONS_FILE}")

# The results are just *potentially* redundant languages
for LANGUAGE_ID in ${LANGUAGE_IDS}; do
    ! grep -q "${LANGUAGE_ID}" <<< "${LOCATIONS_FILE_CONTENT}" && echo "${LANGUAGE_ID}"
done
