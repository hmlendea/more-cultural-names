#!/bin/bash

TITLES_COUNT=$(cat titles.xml | grep "Name language" | wc -l)
LANGUAGES_COUNT=$(cat languages.xml | grep "/Language>" | wc -l)

echo "Titles: ${TITLES_COUNT}"
echo "Languages: ${LANGUAGES_COUNT}"
