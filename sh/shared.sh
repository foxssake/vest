#!/bin/bash

# Formatting
# See: https://github.com/chalk/ansi-styles/blob/main/index.js
NC="\033[0m";
BOLD="\033[1m";

print() {
  echo -e $@
}

# Version and addon data for build
version="$(grep "version=" addons/vest/plugin.cfg | cut -d"\"" -f2)"

addons=("vest")
declare -A addon_deps=(\
)

# git config
if [[ "$(git config user.name)" == "" ]]; then
  print "Configuring git user"
  git config user.name "Fox's Sake CI"
  git config user.email "ci@foxssake.studio"
fi;

