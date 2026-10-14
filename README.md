# Atlantis Acts Scaffold (Twee source)

The story lives in plain-text Twee 3 files under `src/`, so several people can work at once and merge changes in git.

```
src/
  story.twee              title, StoryData, stylesheet, StoryInit, widgets, menus, Start, Districts, Codex index
  endings.twee            Endings hub and the Best / Good / Bad endings
  acts/act-1.twee ...     one file per act: the act hub and its locations
  characters/<name>.twee  one file per character: their scene in each act plus their Codex entry
assets/img/               art from the team pitch deck, copied to build/img by the build scripts
storyformats/sugarcube-2  SugarCube 2.37.3, so every build uses the same version
```

## Build

1. Tweego 2.1.1 for Windows is included in `tools/tweego/`. On macOS/Linux, install it from https://www.motoslave.net/tweego/.
2. Run `build.cmd` (Windows) or `./build.sh` (macOS/Linux).

This writes two files to `build/`:
- `atlantis-play.html` is the playable game. Open it in a browser.
- `atlantis-twine.html` is a Twine archive. Use Library > Import in Twine to open it in the visual editor.
- `img/` holds the art. Passages show it with `<img src="img/...">`, so keep `img/` next to the HTML when you share the game.

The Twine archive references the same `img/` paths. Twine stores only the passage text, not the pictures, so images appear in Twine only when the published HTML sits next to an `img/` folder.

## Art

Images live in `assets/img/`. Use lowercase descriptive names and keep each file under about 1600px wide and 1MB. Use `<img class="art" src="img/name.jpg" alt="...">` for a full-width banner and `class="portrait"` for a character portrait floated to the right.

## Working in the files

- Each passage starts with `:: Passage Name [tags] {"position":"x,y","size":"100,100"}`. Passage names must be unique across all files.
- Put a new character's passages in `src/characters/<name>.twee`, and add their starting trust to `StoryInit` in `story.twee`.
- If you edit in the Twine app instead, use Build > Export as Twee and copy your changed passages back into the right files. Don't commit a whole exported file over `src/`.
- Tags: `act`, `location`, `character`, `codex`, `ending`, and `todo` for anything that still needs writing.
