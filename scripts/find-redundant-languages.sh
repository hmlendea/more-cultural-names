#!/bin/bash
source "scripts/common/paths.sh"

LANGUAGE_IDS="$(grep "<Id>" "${LANGUAGES_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"
LOCATIONS_FILE_LANGUAGE_IDS=$(grep "<Name language=" "${LOCATIONS_FILE}" | sed 's/^.*language=\"\([^\"]*\).*/\1/g' | sort | uniq)
LANGUAGES_FILE_CONTENT=$(cat "${LANGUAGES_FILE}")

# The results are just *potentially* redundant languages
for LANGUAGE_ID in ${LANGUAGE_IDS}; do
    LANGUAGE_IS_REDUNDANT=true

    if grep -q "${LANGUAGE_ID}" <<< "${LOCATIONS_FILE_LANGUAGE_IDS}" \
    || grep -q "<LanguageId>${LANGUAGE_ID}</LanguageId>" <<< "${LANGUAGES_FILE_CONTENT}" \
    || grep -Pzoq "\n\s*<Id>${LANGUAGE_ID}</Id>.*(\n\s*<Code.*)*\n\s*<(GameId|Fallback)" <<< "${LANGUAGES_FILE_CONTENT}"; then
        LANGUAGE_IS_REDUNDANT=false
    fi

    ${LANGUAGE_IS_REDUNDANT} && echo "Unused langauge: ${LANGUAGE_ID}"
done
