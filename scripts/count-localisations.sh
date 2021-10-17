#!/bin/bash

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"

NAMES_COUNT=$(grep "Name language" "${LOCATIONS_FILE}" | wc -l)
LOCATIONS_COUNT=$(grep "<Id>" "${LOCATIONS_FILE}" | wc -l)
LANGUAGES_COUNT=$(grep "/Language>" "${LANGUAGES_FILE}" | wc -l)

WIKIDATA_LOCATIONS_COUNT=$(grep "<WikidataId>" "${LOCATIONS_FILE}" | wc -l)

function get_game_titles_count() {
    GAME=${1}
    TITLES_COUNT=$(grep "<GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | wc -l)
    echo ${TITLES_COUNT}
}

function print_game_titles_count() {
    GAME=${1}
    TITLES_COUNT=$(get_game_titles_count ${GAME})
    echo "${GAME} titles: ${TITLES_COUNT}" >&2
}

print_game_titles_count CK2
print_game_titles_count CK2HIP
print_game_titles_count CK3
print_game_titles_count CK3IBL
print_game_titles_count CK3MBP
print_game_titles_count HOI4
print_game_titles_count ImperatorRome

echo ""
echo "Names: ${NAMES_COUNT}"
echo "Locations: ${LOCATIONS_COUNT}"
echo "Languages: ${LANGUAGES_COUNT}"

echo ""
echo "Wikidata coverage: ${WIKIDATA_LOCATIONS_COUNT} ($((WIKIDATA_LOCATIONS_COUNT*100/LOCATIONS_COUNT))%)"
