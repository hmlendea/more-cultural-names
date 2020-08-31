#!/bin/bash

MAJOR=$(date +"%y")
MINOR=$(date +"%j")
BUILD=$(date +"%H")

echo ${MAJOR}.${MINOR}.${BUILD}
