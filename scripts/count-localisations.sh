#!/bin/bash
source "scripts/common/paths.sh"

NAMES_COUNT=$(grep -c "Name language" "${LOCATIONS_FILE}")
LOCATIONS_COUNT=$(grep -c "<Id>" "${LOCATIONS_FILE}")
LANGUAGES_COUNT=$(grep -c "/Language>" "${LANGUAGES_FILE}")

WIKIDATA_LOCATIONS_COUNT=$(grep -c "<WikidataId>" "${LOCATIONS_FILE}")
WELL_COVERED_LINES_COUNT=$(grep "\(<Name lang\|@@@@ BELOW TITLES NEED REVIEW\)" "${LOCATIONS_FILE}" | grep -n "@@@@ BELOW TITLES NEED REVIEW" | awk -F":" '{print $1}')

function get_game_locations_count() {
    local GAME=${1}
    local LOCATIONS_COUNT=0

    LOCATIONS_COUNT=$(grep -c "<GameId game=\"${GAME}\"" "${LOCATIONS_FILE}")

    echo "${LOCATIONS_COUNT}"
}

function print_game_locations_count() {
    local GAME=${1}
    local LOCATIONS_COUNT=0

    LOCATIONS_COUNT=$(get_game_locations_count "${GAME}")

    echo "${GAME} locations: ${LOCATIONS_COUNT}" >&2
}

print_game_locations_count CK2
print_game_locations_count CK2HIP
print_game_locations_count CK2TWK
print_game_locations_count CK3
print_game_locations_count CK3ATHA
print_game_locations_count CK3CMH
print_game_locations_count CK3IBL
print_game_locations_count CK3MBP
print_game_locations_count CK3SoW
print_game_locations_count CK3TBA
print_game_locations_count CK3TFE
print_game_locations_count HOI4
print_game_locations_count HOI4MDM
print_game_locations_count HOI4TGW
print_game_locations_count IR
print_game_locations_count IR_AoE

echo ""
echo "Names: ${NAMES_COUNT}"
echo "Locations: ${LOCATIONS_COUNT}"
echo "Languages: ${LANGUAGES_COUNT}"

echo ""
echo "Well-covered locations: $((WIKIDATA_LOCATIONS_COUNT*100/LOCATIONS_COUNT))% (${WIKIDATA_LOCATIONS_COUNT} locations)"
echo "Well-covered names: $((WELL_COVERED_LINES_COUNT*100/NAMES_COUNT))% (${WELL_COVERED_LINES_COUNT} names)"
