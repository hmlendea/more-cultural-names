#!/bin/bash

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
grep "><" titles.xml
grep "><" languages.xml

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

# Find multiple name definitions for the same language
pcregrep -M "language=\"([^\"]*)\".*\n.*language=\"\1\"" titles.xml
