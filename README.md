# Atlantis Acts Scaffold (Twee source)

**Writers: start with [HOW-TO-EDIT.md](HOW-TO-EDIT.md).** It explains how to edit the story and preview it, with no setup beyond a browser.

The story lives in plain-text Twee 3 files under `src/`, so several people can work at once and merge changes in git.

```
src/
  story.twee              title, StoryData, stylesheet, StoryInit, widgets, menus, Start, Districts, Codex index
  endings.twee            Endings hub and the Best / Good / Bad endings
  acts/act-1.twee ...     one file per act: the act hub and its locations
  characters/<name>.twee  one file per character: their scene in each act plus their Codex entry
assets/img/               art from the team pitch deck, copied to build/img by the build scripts
assets/audio/             background music, copied to build/audio by the build scripts
storyformats/sugarcube-2  SugarCube 2.37.3, so every build uses the same version
```

## Build

1. Tweego 2.1.1 for Windows and macOS is included in `tools/tweego/` (`tweego.exe` and `tweego-macos`). On Linux, install it from https://www.motoslave.net/tweego/.
2. Run `build.cmd` (Windows) or `./build.sh` (macOS/Linux). To build and open the game in one step, double-click `preview.cmd` or `preview.command`.
   - macOS: if it is blocked, run `xattr -d com.apple.quarantine tools/tweego/tweego-macos`. The binary is Intel (x64), so Apple Silicon Macs may prompt to install Rosetta once.
   - `build.sh` uses `$TWEEGO` if set, then `tools/tweego/tweego`, then `tools/tweego/tweego-macos` on macOS, then `tweego` on your PATH.

This writes two files to `build/`:
- `atlantis-play.html` is the playable game. Open it in a browser.
- `atlantis-twine.html` is a Twine archive. Use Library > Import in Twine to open it in the visual editor.
- `audio/` holds the music. Keep it next to the HTML too.
- `img/` holds the art. Passages show it with `<img src="img/...">`, so keep `img/` next to the HTML when you share the game.

The Twine archive references the same `img/` paths. Twine stores only the passage text, not the pictures, so images appear in Twine only when the published HTML sits next to an `img/` folder.

## Playtesting online

The latest build is playable at https://asgc-game-jam.github.io/narrative-twine/, so playtesters don't need to build anything.

- `.github/workflows/pages.yml` rebuilds and redeploys the site on every push to `main`. You can also run it by hand from the Actions tab.
- The site serves everything in `build/`. `index.html` opens the game, and the Twine archive is at `atlantis-twine.html`.
- Pages only has to be enabled once, under Settings > Pages > Source: GitHub Actions.

## Art

Images live in `assets/img/`. Use lowercase descriptive names and keep each file under about 1600px wide and 1MB. Use `<img class="art" src="img/name.jpg" alt="...">` for a full-width banner and `class="portrait"` for a character portrait floated to the right.

## Working in the files

- Each passage starts with `:: Passage Name [tags] {"position":"x,y","size":"100,100"}`. Passage names must be unique across all files.
- Put a new character's passages in `src/characters/<name>.twee`, and add their starting trust to `StoryInit` in `story.twee`.
- If you edit in the Twine app instead, use Build > Export As Twee, save the file in the repo folder and run `import-from-twine.cmd` (Windows) or `import-from-twine.command` (macOS). It replaces changed passages in the files they already live in, puts new ones in `src/new-passages.twee`, removes passages deleted in Twine, never changes StoryData, matches the stylesheet and script by tag, backs up `src` to `.backup/` (gitignored), and rebuilds. It stops without changing anything if the export would remove more than a quarter of the passages. The logic is in `tools/import-from-twine.ps1` (Windows) and `tools/import-from-twine.sh` with `tools/import-from-twine.awk` (macOS); keep them in step.
- Tags: `act`, `location`, `character`, `codex`, `ending`, and `todo` for anything that still needs writing.

## Music

Tracks live in `assets/audio/` as MP3s (about 128 kbps keeps them small). The music code is in the `Story JavaScript` passage in `src/story.twee`, so passages need no music markup:

| Track | Plays on |
| --- | --- |
| `main-menu` | Start, Act 4, Endings |
| `tutorial` | Act 1 |
| `hub-area` | Acts 2 and 3 |

- The track is picked from the passage name (`byPassage`) or its tags (`byTag`, e.g. `act2`). Passages that match neither, such as the Codex and the Districts map, keep the current track playing.
- Tracks loop and crossfade over 1.5 seconds. Volume is 0.5.
- Browsers block sound until the player clicks, so music starts on the first click or key press.
- Players can turn music off with "Music on/off" in the sidebar menu or in Settings.

To change where a track plays, edit `byPassage` and `byTag`. To add a track, put the MP3 in `assets/audio/`, add a `<<cacheaudio "id" "audio/file.mp3">>` line to `StoryInit`, add the id to `tracks`, and map it in `byTag` or `byPassage`.
