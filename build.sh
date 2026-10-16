#!/bin/sh
# Builds the story from src/ with Tweego (https://www.motoslave.net/tweego/).
# Output: build/atlantis-play.html (play in a browser) and build/atlantis-twine.html (Library > Import in Twine).
cd "$(dirname "$0")"
# Tweego to use: $TWEEGO if set, else a bundled binary, else tweego on PATH.
if [ -z "$TWEEGO" ]; then
  if [ -x tools/tweego/tweego ]; then
    TWEEGO=tools/tweego/tweego
  elif [ "$(uname -s)" = Darwin ] && [ -f tools/tweego/tweego-macos ]; then
    chmod +x tools/tweego/tweego-macos 2>/dev/null
    TWEEGO=tools/tweego/tweego-macos
  else
    TWEEGO=tweego
  fi
fi
mkdir -p build
export TWEEGO_PATH="$PWD/storyformats"
"$TWEEGO" -o build/atlantis-play.html src || exit 1
"$TWEEGO" -a -o build/atlantis-twine.html src || exit 1
# Images and music are referenced as img/<file> and audio/<file> relative to the built HTML.
rm -rf build/img && cp -R assets/img build/img || exit 1
rm -rf build/audio && cp -R assets/audio build/audio || exit 1
echo "Built build/atlantis-play.html and build/atlantis-twine.html (with build/img and build/audio)"
