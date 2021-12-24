#!/bin/bash

STARTDIR="$(pwd)"
MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_VERSION=$(curl --silent "https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/latest" | sed 's/.*\/tag\/v\([^\"]*\)">redir.*/\1/g')
MOD_BUILDER_PACKAGE_NAME="${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_PACKAGE_URL="https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_PACKAGE_NAME}"
NEEDS_DOWNLOADING=true

echo "Checking for builder updates..."
if [ -d "${STARTDIR}/${MOD_BUILDER_NAME}" ]; then
    if [ -f "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt" ]; then
        CURRENT_VERSION=$(cat "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt")
        if [ "${CURRENT_VERSION}" == "${MOD_BUILDER_VERSION}" ]; then
            NEEDS_DOWNLOADING=false
        fi
    fi
fi

if [ ${NEEDS_DOWNLOADING} == true ]; then
    [ -d "${STARTDIR}/${MOD_BUILDER_NAME}" ] && rm -rf "${STARTDIR:?}/${MOD_BUILDER_NAME:?}"

    echo " > Downloading v${MOD_BUILDER_VERSION}..."
    wget -q -c "${MOD_BUILDER_PACKAGE_URL}"
    
    echo " > Extracting..."
    mkdir "${STARTDIR}/${MOD_BUILDER_NAME}"
    unzip -q "${STARTDIR}/${MOD_BUILDER_PACKAGE_NAME}" -d "${STARTDIR}/${MOD_BUILDER_NAME}"
    echo "${MOD_BUILDER_VERSION}" > "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt"
fi
