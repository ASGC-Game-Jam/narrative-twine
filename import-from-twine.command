#!/bin/sh
# Double-click in Finder after saving a Twine "Export As Twee" file into this folder.
exec bash "$(dirname "$0")/tools/import-from-twine.sh"
