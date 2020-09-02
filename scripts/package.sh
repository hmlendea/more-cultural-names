#!/bin/bash

STARTDIR="$(pwd)"
OUTDIR="$STARTDIR/out"
VERSION=${1}

if [ -z "${VERSION}" ]; then
    echo "ERROR: Please specify a version"
    exit 1
fi

function build {
    GAME=${1}
    INDIR="out/${GAME}/"
    ZIPNAME=${GAME}_${VERSION}

    echo "Building the '${INDIR}' package..."

    zip -q -r "${ZIPNAME}.zip" "${INDIR}"
    mv "${ZIPNAME}.zip" "${OUTDIR}/"
}

build "CK2HIP"
build "CK3"
build "ImperatorRome"
