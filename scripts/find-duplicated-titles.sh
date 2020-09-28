#!/bin/bash

LOCATIONS_FILE="locations.xml"
LEVEL=${1}

if [ ${LEVEL} == 1 ]; then
grep "<Id>" "${LOCATIONS_FILE}" | \
    sed 's/^ *<Id>\([^<]*\).*/\1/g' | \
    sed 's/[_-]//g' | \

    sort | uniq -c | \
    grep "^ *[2-9]" | \
    awk '{print $2}' | \

    sed 's/\([a-z]\)/\1\[_-\]\*/g' | \
    sed 's/\(.*\)/<Id>\1<\/Id>/g'
fi

if [ ${LEVEL} == 2 ]; then
grep "<Id>" "${LOCATIONS_FILE}" | \
    sed 's/^ *<Id>\([^<]*\).*/\1/g' | \
    sed 's/\([a-dfi-z]\)\(\1\)*/\1/g' | \

    sort | uniq -c | \
    grep "^ *[2-9]" | \
    awk '{print $2}' | \

    grep '.\{6,111\}' | \

    sed 's/\([a-dfi-z]\)/\1\+/g' | \
    sed 's/\(.*\)/<Id>\1<\/Id>/g'
fi

if [ ${LEVEL} == 3 ]; then
grep "<Id>" "${LOCATIONS_FILE}" | \
    sed 's/^ *<Id>\([^<]*\).*/\1/g' | \
    sed 's/\([a-dfi-z]\)\(\1\)*/\1/g' | \

    sort | uniq -c | \
    grep "^ *[2-9]" | \
    awk '{print $2}' | \

    grep '.\{5,111\}' | \

    sed 's/[kK]/c/g' | \
    sed 's/[yYjJ]/i/g' | \
    sed 's/[zZ]/s/g' | \
    sed 's/[vVwWuU]/b/g' | \

    sed 's/c/\[kKcC\]\+/g' | \
    sed 's/i/\[yYjJiI\]\+/g' | \
    sed 's/s/\[zZsS\]\+/g' | \
    sed 's/m/\[nNmM\]\+/g' | \
    sed 's/b/\[vVwWuUbB\]\+/g' | \

    sed 's/\([adflo-rtx-z]\)/\1\+/g' | \
    sed 's/\(.*\)/<Id>\1<\/Id>/g'
fi

if [ ${LEVEL} == 4 ]; then
grep "<Id>" "${LOCATIONS_FILE}" | \
    sed 's/^ *<Id>\([^<]*\).*/\1/g' | \
    sed 's/[yYjJ]/i/g' | \
    sed 's/[zZ]/s/g' | \
    sed 's/[nN]/m/g' | \
    sed 's/[vVwWuU]/b/g' | \
    sed 's/[qQkK]/c/g' | \
    sed 's/[pP][hH]/f/g' | \
    sed 's/\([a-z]\)\(\1\)*/\1/g' | \

    sort | uniq -c | \
    grep "^ *[2-9]" | \
    awk '{print $2}' | \

    sed 's/\([adeghlmnoprtx]\)/\1\+/g' | \
    sed 's/i/\[yYjJiI\]\+/g' | \
    sed 's/s/\[zZsS\]\+/g' | \
    sed 's/m/\[nNmM\]\+/g' | \
    sed 's/b/\[vVwWuUbB\]\+/g' | \
    sed 's/c/\[qQkKcC\]\+/g' | \
    sed 's/f/(f\+|[pP][hH])/g' | \
    sed 's/\(.*\)/<Id>\1<\/Id>/g'
fi