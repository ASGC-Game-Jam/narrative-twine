#!/bin/sh
# Builds the story from src/ with Tweego (https://www.motoslave.net/tweego/).
# Output: build/atlantis-play.html (play in a browser) and build/atlantis-twine.html (Library > Import in Twine).
cd "$(dirname "$0")"
TWEEGO="${TWEEGO:-tweego}"
[ -x tools/tweego/tweego ] && TWEEGO=tools/tweego/tweego
mkdir -p build
export TWEEGO_PATH="$PWD/storyformats"
"$TWEEGO" -o build/atlantis-play.html src || exit 1
"$TWEEGO" -a -o build/atlantis-twine.html src || exit 1
# Images are referenced as img/<file> relative to the built HTML.
rm -rf build/img && cp -R assets/img build/img || exit 1
echo "Built build/atlantis-play.html and build/atlantis-twine.html (with build/img)"
