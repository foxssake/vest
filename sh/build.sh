#!/bin/bash

BOLD="$(tput bold)"
NC="$(tput sgr0)"

ROOT="$(pwd)"
BUILD="$ROOT/build"
TMP="$ROOT/buildtmp"

# Assume we're running from project root
source sh/shared.sh

# Grab commit history
print $BOLD"Unshallowing commit history"$NC
git fetch --unshallow --filter=tree:0

print $BOLD"Building vest v${version}" $NC

print "Directories"
print "Root: $ROOT"
print "Build: $BUILD"
print "Temp: $TMP"

rm -rf "$BUILD"
mkdir -p "$BUILD"
rm -rf "$TMP"

for addon in ${addons[@]}; do
    print "Packing addon ${addon}"

    addon_tmp="$TMP/${addon}.v${version}/addons"
    addon_src="$ROOT/addons/${addon}"
    addon_dst="$BUILD/${addon}.v${version}"

    # Copy addon source
    mkdir -p "${addon_tmp}"
    cd "$TMP"
    cp -r "${addon_src}" "${addon_tmp}"

    has_deps="false"
    for dep in ${addon_deps[$addon]}; do
      print "Adding dependency $dep"
      cp -r "$ROOT/addons/${dep}" "${addon_tmp}"
      "$ROOT/sh/contributors.sh" > "${addon_tmp}/${dep}/CONTRIBUTORS.md"
      has_deps="true"
    done

    # Copy script templates
    cp -r "$ROOT/script_templates" "./${addon}.v${version}"

    zip -r "${addon_dst}.zip" "${addon}.v${version}" "script_templates"

    cd "$ROOT"
    rm -rf "$TMP"
done

# Build docs
print $BOLD"Building docs" $NC
mkdocs build --no-directory-urls
cd site
zip -r "../build/vest.docs.v${version}.zip" ./*
cd ..
rm -rf site

