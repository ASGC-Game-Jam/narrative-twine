#!/bin/bash
# Sorts a Twine "Build > Export As Twee" file back into the src/*.twee files (macOS).
# Run it with import-from-twine.command. Same rules as tools/import-from-twine.ps1; the merge is in import-from-twine.awk.
cd "$(dirname "$0")/.." || exit 1

wait_key() {
	echo
	printf "Press Return to close this window. "
	read -r _
}

# 1. Find the newest exported .twee file.
export_file=$(ls -t ./*.twee twine-export/*.twee 2>/dev/null | head -n 1)
if [ -z "$export_file" ]; then
	echo "No Twine export found."
	echo
	echo "In Twine, open the story and choose Build > Export As Twee."
	echo "Save the file into this folder ($PWD), then double-click import-from-twine again."
	wait_key; exit 1
fi
echo "Importing ${export_file#./}"
echo

# 2. Merge into a staging folder.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
files=()
while IFS= read -r f; do files+=("$f"); done < <(find src -type f -name '*.twee' | LC_ALL=C sort)
while IFS= read -r d; do mkdir -p "$stage/$d"; done < <(find src -type d)
if ! LC_ALL=C awk -v out="$stage" -f tools/import-from-twine.awk "$export_file" "${files[@]}" > "$stage/report"; then
	echo "Something went wrong while reading the files. Nothing was changed. Ask for help in the team chat."
	wait_key; exit 1
fi

report() { grep "^$1	" "$stage/report" | cut -f 2-; }
count() { grep -c "^$1	" "$stage/report"; }
report WARN | sed 's/^/Warning: /'
total=$(report TOTAL)
updated=$(count UPDATED); added=$(count ADDED); removed=$(count REMOVED); changed=$(count CHANGED)

# Guard against importing the wrong story.
if [ "$removed" -gt 5 ] && [ $((removed * 4)) -gt "$total" ]; then
	echo "Stopped: this would remove $removed of $total passages, so the export is probably a different or older story."
	echo "Nothing was changed. Check that you exported the right story from Twine."
	wait_key; exit 1
fi

# 3. Back up src, then copy in the changed files.
stamp=$(date +%Y%m%d-%H%M%S)
mkdir -p .backup
if [ "$changed" -eq 0 ]; then
	echo "No changes: the export matches the files in src."
else
	cp -R src ".backup/src-$stamp"
	report CHANGED | while IFS= read -r f; do cp "$stage/$f" "$f"; done
	echo "Backup of the old src folder: .backup/src-$stamp"
fi

# 4. Move the export out of the way so it isn't imported twice.
base=$(basename "$export_file" .twee)
mv "$export_file" ".backup/$base-$stamp.twee"

# 5. Rebuild so mistakes show up now.
echo
echo "Building the game..."
sh ./build.sh
build_ok=$?

echo
echo "----------------------------------------"
echo "$updated passages updated"
report UPDATED | awk -F '\t' '{ print "    " $1 " (" $2 ")" }'
echo "$added new passages added to src/new-passages.twee"
report ADDED | sed 's/^/    /'
echo "$removed passages removed (they are not in the Twine export)"
report REMOVED | awk -F '\t' '{ print "    " $1 " (" $2 ")" }'
echo
if [ "$build_ok" -eq 0 ]; then
	echo "The game built without errors."
	[ "$changed" -gt 0 ] && echo "Now commit in GitHub Desktop."
else
	echo "The game did NOT build. The message above names the file and line to fix."
	echo "Your old files are in the .backup folder if you need them."
fi
wait_key
[ "$build_ok" -eq 0 ]
