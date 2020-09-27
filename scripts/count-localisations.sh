#!/bin/bash

NAMES_COUNT=$(grep "Name language" titles.xml | wc -l)
LANGUAGES_COUNT=$(grep "/Language>" languages.xml | wc -l)

function get_game_titles_count() {
    GAME=${1}
    TITLES_COUNT=$(grep "<GameId game=\"${GAME}\"" titles.xml | wc -l)
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
print_game_titles_count HOI4
print_game_titles_count ImperatorRome
echo ""
echo "Names: ${NAMES_COUNT}"
echo "Languages: ${LANGUAGES_COUNT}"
