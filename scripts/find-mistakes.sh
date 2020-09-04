#!/bin/bash

grep -n "parent=\"\([^\"]*\)\"[^>]*>\1<" titles.xml
grep -n "parent=\"[a-zA-Z][^_]" titles.xml