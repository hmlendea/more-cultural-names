#!/bin/bash

MOD_BUILDER_VERSION="1.2.1"
MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_ZIP_URL="https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_BIN_FILE_PATH="${MOD_BUILDER_NAME}/MoreCulturalNamesModBuilder"

if [ -n "$(sh scripts/find-mistakes.sh)" ]; then
    echo "Input files validation failed!"
    exit 1
fi

if [ ! -d ${MOD_BUILDER_NAME} ]; then
    wget -c ${MOD_BUILDER_ZIP_URL}
    mkdir ${MOD_BUILDER_NAME}
    unzip ${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip -d ${MOD_BUILDER_NAME}
fi

function build {
    "${MOD_BUILDER_BIN_FILE_PATH}" -l "languages.xml" -t "titles.xml" -o "out/"
}

[ -d "out/" ] && rm -rf "out/"

build

cp -rf extras/ck2hip/* out/CK2HIP/
cp -rf extras/ck3/* out/CK3/
cp -rf extras/ir/* out/ImperatorRome/

rm out/CK2HIP/descriptor.mod
