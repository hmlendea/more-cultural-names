#!/bin/bash

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

CK3_VANILLA_LOCALISATION_FILE="/home/horatiu/.games/Steam/common/Crusader Kings III/game/localization/english/titles_l_english.yml"
IMPERATORROME_VANILLA_LOCALISATION_FILE="/home/horatiu/.games/Steam/common/ImperatorRome/game/localization/english/provincenames_l_english.yml"

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
        echo "Fallback location \"${FALLBACK_LOCATION_ID}\" does not exist"
    fi
done

# Find non-existing fallback titles
for FALLBACK_TITLE_ID in $(grep "<TitleId>" "${TITLES_FILE}" | \
                                sed 's/.*<TitleId>\([^<>]*\)<\/TitleId>.*/\1/g' | \
                                sort | uniq); do
    if [ -z "$(grep "<Id>${FALLBACK_TITLE_ID}</Id>" "${TITLES_FILE}")" ]; then
        echo "Fallback title \"${FALLBACK_TITLE_ID}\" does not exist"
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

# Validate Crusader Kings 3 province IDs
if [ -f "${CK3_VANILLA_LOCALISATION_FILE}" ]; then
    for PROV in $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"CK3\"" | sed 's/^.*>\([^<]*\)<\/GameId.*!-- *\(.*\) *-->.*/\1|\2/g' | sed 's/ /@/g' | sort); do
        PROV_ID=$(echo "${PROV}" | awk -F\| '{print $1}')
        PROV_NAME=$(echo "${PROV}" | awk -F\| '{print $2}' | sed 's/@/ /g' | sed 's/^ *//g' | sed 's/ *$//g')

        FOUND_LINE=$(cat "${CK3_VANILLA_LOCALISATION_FILE}" | grep "${PROV_ID}:" | grep "${PROV_NAME}")

        if [ -z "${FOUND_LINE}" ]; then
            echo "${PROV_ID} (${PROV_NAME}) is different from vanilla!"
        fi
    done
fi

# Validate ImperatorRome province IDs
if [ -f "${IMPERATORROME_VANILLA_LOCALISATION_FILE}" ]; then
    for PROV in $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"ImperatorRome\"" | sed 's/^.*>\([0-9]*\)<\/GameId.*!-- *\(.*\) *-->.*/\1_\2/g' | sed 's/ /@/g' | sort); do
        PROV_ID=$(echo "${PROV}" | awk -F_ '{print $1}')
        PROV_NAME=$(echo "${PROV}" | awk -F_ '{print $2}' | sed 's/@/ /g' | sed 's/^ *//g' | sed 's/ *$//g')

        FOUND_LINE=$(cat "${IMPERATORROME_VANILLA_LOCALISATION_FILE}" | grep "PROV${PROV_ID}:" | grep "${PROV_NAME}")

        if [ -z "${FOUND_LINE}" ]; then
            echo "${PROV_ID} (${PROV_NAME}) is different from vanilla!"
        fi
    done
fi
