#!/bin/sh
# Double-click in Finder to build the game and open it in your browser.
cd "$(dirname "$0")" || exit 1
if sh ./build.sh; then
  open build/atlantis-play.html
else
  echo
  echo "The game could not be built. The message above names the file and line to fix."
  printf "Press Return to close this window. "
  read -r _
  exit 1
fi
