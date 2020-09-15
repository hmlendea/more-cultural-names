#!/bin/bash

grep -n "parent=\"\([^\"]*\)\"[^>]*>\1<" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml

# Find duplicated IDs
grep "^ *<Id>" *.xml | sort | uniq -c | grep "^ *[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed 's/ \(parent\|order\)=\"[^\"]*\"//g' | \
    sed 's/[ \t]*<!--.*-->.*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find non-existing fallback locations
for FALLBACK_LOCATION_ID in $(grep "<LocationId>" titles.xml | \
                                sed 's/.*<LocationId>\([^<>]*\)<\/LocationId>.*/\1/g' | \
                                sort | uniq); do
    if [ -z "$(grep "<Id>"${FALLBACK_LOCATION_ID} titles.xml)" ]; then
        echo "Fallback location \"${FALLBACK_LOCATION_ID}\" does not exit"
    fi
done

# Find non-existing name languages
for LANGUAGE_ID in $(grep "<Name " titles.xml | \
                    sed 's/.*language=\"\([^\"]*\).*/\1/g' | \
                    sort | uniq); do
    if [ -z "$(grep "^ *<Id>${LANGUAGE_ID}</Id>" languages.xml)" ]; then
        echo "The \"${LANGUAGE_ID}\" language does not exit"
    fi
done

# Find non-existing location parents (CK2HIP)
for PARENT_ID in $(grep "game=\"CK2HIP\"" titles.xml | \
                    grep -e "parent=\"[^\"]\+\"" | \
                    sed 's/.*parent=\"\([^\"]*\)".*/\1/g' | \
                    sort | uniq); do
    if [ -z "$(grep "<GameId game=\"CK2HIP\"" titles.xml | grep ">"${PARENT_ID}"<")" ]; then
        echo "CK2HIP: ${PARENT_ID} entry does not exit"
    fi
done
