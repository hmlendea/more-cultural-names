#!/bin/bash

grep -n "parent=\"\([^\"]*\)\"[^>]*>\1<" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml
grep "GameId game=\"ImperatorRome\"" titles.xml | sed 's/[ \t]*<!--.*-->[ \t]*//g' | sort | uniq -c | sed 's/^[ \t]*//g' | grep "^[2-9]"