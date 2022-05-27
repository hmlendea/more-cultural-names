#!/bin/bash
source "scripts/common/paths.sh"

GITHUB_BASE_URL="https://github.com"
MOD_BUILDER_AUTHOR="hmlendea"
MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_REPOSITORY="${MOD_BUILDER_AUTHOR}/${MOD_BUILDER_NAME}"
MOD_BUILDER_REPOSITORY_URL="${GITHUB_BASE_URL}/${MOD_BUILDER_REPOSITORY}"
MOD_BUILDER_DIRECTORY="${REPO_DIR}/.builder"
MOD_BUILDER_VERSION=$(curl --silent "https://api.github.com/repos/${MOD_BUILDER_REPOSITORY}/releases/latest" | grep tag_name | sed 's/[^:]*: \"v\([^\"]*\).*/\1/g')
NEEDS_DOWNLOADING=true

echo "Checking for builder updates..."
if [ -d "${MOD_BUILDER_DIRECTORY}" ]; then
    if [ -f "${MOD_BUILDER_DIRECTORY}/version.txt" ]; then
        CURRENT_VERSION=$(cat "${MOD_BUILDER_DIRECTORY}/version.txt")
        if [ "${CURRENT_VERSION}" == "${MOD_BUILDER_VERSION}" ]; then
            NEEDS_DOWNLOADING=false
        fi
    fi
fi

if ${NEEDS_DOWNLOADING}; then
    [ -d "${MOD_BUILDER_DIRECTORY}" ] && rm -rf "${MOD_BUILDER_DIRECTORY:?}"

    MOD_BUILDER_PACKAGE_NAME="${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
    MOD_BUILDER_PACKAGE_URL="${MOD_BUILDER_REPOSITORY_URL}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_PACKAGE_NAME}"
    MOD_BUILDER_PACKAGE_FILE="${REPO_DIR}/.${MOD_BUILDER_PACKAGE_NAME}"

    echo " > Downloading v${MOD_BUILDER_VERSION}..."
    wget -q -c "${MOD_BUILDER_PACKAGE_URL}" -O "${MOD_BUILDER_PACKAGE_FILE}" 2>/dev/null

    echo " > Extracting..."
    mkdir "${MOD_BUILDER_DIRECTORY}"
    unzip -q "${MOD_BUILDER_PACKAGE_FILE}" -d "${MOD_BUILDER_DIRECTORY}"
    echo "${MOD_BUILDER_VERSION}" > "${MOD_BUILDER_DIRECTORY}/version.txt"

    echo " > Cleaning up..."
    rm "${MOD_BUILDER_PACKAGE_FILE}"
fi
