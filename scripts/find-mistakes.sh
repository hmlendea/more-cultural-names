#!/bin/bash

grep -n "parent=\"\([^\"]*\)\"[^>]*>\1<" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml

# Find duplicated Imperator: Rome game IDs
grep "GameId game=\"ImperatorRome\"" titles.xml | sed 's/[ \t]*<!--.*-->[ \t]*//g' | sort | uniq -c | sed 's/^[ \t]*//g' | grep "^[2-9]"

# Find CK2 parents missing an entry
for PARENT_ID in $(grep "game=\"CK2HIP\"" titles.xml | \
                    grep -e "parent=\"[^\"]\+\"" | \
                    sed 's/.*parent=\"\([^\"]*\)".*/\1/g' | \
                    sort | uniq); do
    if [ -z "$(grep "<GameId game=\"CK2HIP\"" titles.xml | grep ">"${PARENT_ID}"<")" ]; then
        echo "CK2HIP: ${PARENT_ID} entry does not exit"
    fi
done
