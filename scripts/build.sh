#!/bin/bash

MOD_BUILDER_VERSION="1.1.0"
MOD_BUILDER_ZIP_URL="https://github.com/hmlendea/mcn-mod-builder/releases/download/v${MOD_BUILDER_VERSION}/mcn-mod-builder_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_BIN_FILE_PATH="mcn-mod-builder/MoreCulturalNamesModBuilder"

if [ ! -d "mcn-mod-builder" ]; then
    wget -c ${MOD_BUILDER_ZIP_URL}
    mkdir mcn-mod-builder
    unzip mcn-mod-builder_${MOD_BUILDER_VERSION}_linux-x64.zip -d mcn-mod-builder
fi

function build {
    "${MOD_BUILDER_BIN_FILE_PATH}" -l "languages.xml" -t "titles.xml" -o "out/"
}

build

cp -rf extras/ck2hip/* out/CK2HIP/
