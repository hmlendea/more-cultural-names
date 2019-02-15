#!/bin/bash

STARTDIR="$(pwd)"
MODNAME="hip-more-cultural-names"
OUTDIR="$STARTDIR/out"

BUILDDIR="$STARTDIR/build"
BUILDDIR_DEFAULT="$BUILDDIR/default"
BUILDDIR_STEAM="$BUILDDIR/steam"

[ ! -d "$OUTDIR" ] && mkdir "$OUTDIR"
[ ! -d "$BUILDDIR" ] && mkdir "$BUILDDIR"
[ ! -d "$BUILDDIR_DEFAULT" ] && mkdir "$BUILDDIR_DEFAULT"
[ ! -d "$BUILDDIR_STEAM" ] && mkdir "$BUILDDIR_STEAM"

NAMES_COUNT=$(cat hip-more-cultural-names/common/landed_titles/0_HIP_MoreCulturalNames.txt | grep " * = *\".*\"" | sed 's/\(\ \|\t\)//g' | grep -Ev "{|}|^#|^$" | wc -l)

function buildDefault {
    echo "Building the default package..."

    [ "$(ls -A "$BUILDDIR_DEFAULT")" ] && rm -rf "$BUILDDIR_DEFAULT/*"

    cp -R "./$MODNAME" "$BUILDDIR_DEFAULT/"
    cp "./$MODNAME.mod" "$BUILDDIR_DEFAULT/"

    sed -i 's/^path.*/path\ =\ \"mod\/'$MODNAME'\"/g' "$BUILDDIR_DEFAULT/$MODNAME.mod"

    cd "$BUILDDIR_DEFAULT"
    zip -q -r "${MODNAME}_default.zip" "./"
    mv "${MODNAME}_default.zip" "$OUTDIR/"

    cd "$STARTDIR"

    echo "Done!"
}

function buildSteam {
    echo "Building the Steam package..."

    [ "$(ls -A "$BUILDDIR_STEAM")" ] && rm -rf "$BUILDDIR_STEAM"

    cp -R "./$MODNAME/." "$BUILDDIR_STEAM/"
    cp "./$MODNAME.mod" "$BUILDDIR_STEAM/descriptor.mod"

    sed -i 's/^path.*/path\ =\ \"mod\/'$MODNAME.zip'\"/g' "$BUILDDIR_STEAM/descriptor.mod"

    cd "$BUILDDIR_STEAM"
    zip -q -r "${MODNAME}_steam.zip" "./"
    mv "${MODNAME}_steam.zip" "$OUTDIR/"

    cd "$STARTDIR"

    echo "Done!"
}

buildDefault
buildSteam

echo "Current number of dynamic names: $NAMES_COUNT"

