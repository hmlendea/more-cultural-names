#!/bin/bash

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

# Find duplicated IDs
grep "^ *<Id>" *.xml | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed 's/[ \t]*<!--.*-->.*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find empty definitions
grep "><" "${LOCATIONS_FILE}"
grep "><" "${LANGUAGES_FILE}"
grep "><" "${TITLES_FILE}"

# Find non-existing fallback locations
for FALLBACK_LOCATION_ID in $(grep "<LocationId>" "${LOCATIONS_FILE}" | \
                                sed 's/.*<LocationId>\([^<>]*\)<\/LocationId>.*/\1/g' | \
                                sort | uniq); do
    if [ -z "$(grep "<Id>${FALLBACK_LOCATION_ID}</Id>" "${LOCATIONS_FILE}")" ]; then
        echo "Fallback location \"${FALLBACK_LOCATION_ID}\" does not exit"
    fi
done

# Find non-existing fallback titles
for FALLBACK_TITLE_ID in $(grep "<TitleId>" "${TITLES_FILE}" | \
                                sed 's/.*<TitleId>\([^<>]*\)<\/TitleId>.*/\1/g' | \
                                sort | uniq); do
    if [ -z "$(grep "<Id>${FALLBACK_TITLE_ID}</Id>" "${TITLES_FILE}")" ]; then
        echo "Fallback title \"${FALLBACK_TITLE_ID}\" does not exit"
    fi
done

# Find non-existing name languages
for LANGUAGE_ID in $(grep "<Name " *.xml | \
                    sed 's/.*language=\"\([^\"]*\).*/\1/g' | \
                    sort | uniq); do
    if [ -z "$(grep "^ *<Id>${LANGUAGE_ID}</Id>" "${LANGUAGES_FILE}")" ]; then
        echo "The \"${LANGUAGE_ID}\" language does not exit"
    fi
done

# Find multiple name definitions for the same language
pcregrep -M "language=\"([^\"]*)\".*\n.*language=\"\1\"" *.xml
