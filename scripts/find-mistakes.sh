#!/bin/bash

grep -n "parent=\"\([^\"]*\)\"[^>]*>\1<" titles.xml
grep -n "CK3\"[^>]*>b_" titles.xml | grep -v "province"
grep -n "parent=\"[a-zA-Z][^_]" titles.xml
grep "GameId game=\"CK3\"" titles.xml | grep "province=" | sed 's/.*province=\"\([^\"]*\)\".*/\1/g' | sort | uniq -c | sed 's/^ *//g' | grep "^[2-9]" | awk '{print $2}' | xargs -I '{}' grep -n "province=\""'{}'"\"" titles.xml