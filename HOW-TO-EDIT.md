# How to edit the story

The story is a set of text files in the `src` folder. You change the text, and the playtest site rebuilds itself:
**https://asgc-game-jam.github.io/narrative-twine/**

You need write access to the repo to save changes. Ask Xelnath if you don't have it.

## Option A: Edit on the GitHub website (nothing to install)

1. Open https://github.com/ASGC-Game-Jam/narrative-twine and sign in.
2. Click `src`, then the file you want, for example `characters` > `castella.twee`.
3. Click the pencil icon (top right of the file) and make your changes.
4. Click **Commit changes**, add a short note about what you changed, and click **Commit changes** again.
5. After about a minute, refresh the playtest site to see your change. If it doesn't show up, look at the **Actions** tab on GitHub: a red X means the build failed (see "If something breaks" below).

## Option B: Edit on your own computer (GitHub Desktop)

1. Install GitHub Desktop (free): https://desktop.github.com/. Sign in, then **File > Clone repository** and pick `ASGC-Game-Jam/narrative-twine`.
2. Open the `.twee` files in the `src` folder with any text editor (Notepad, TextEdit, VS Code).
3. To see the game, double-click **preview.cmd** (Windows) or **preview.command** (Mac). It builds the game and opens it in your browser.
   - Mac, first time: if macOS says it can't open the file, right-click **preview.command**, choose **Open**, then **Open** again. Apple Silicon Macs may ask to install Rosetta once; say yes.
4. When you're happy, go back to GitHub Desktop: write a short summary, click **Commit to main**, then **Push origin**. Click **Fetch origin** before you start each session to get everyone else's changes.

## Option C: The Twine visual editor

Twine (https://twinery.org) shows the story as a map of connected boxes. To bring your changes back you also need Option B set up.

1. Open the playtest site and click **Download for Twine** in the left sidebar. (Or right-click https://asgc-game-jam.github.io/narrative-twine/atlantis-twine.html and choose **Save link as**.) The file always matches the latest version on GitHub, about a minute after each change.
   - Using GitHub Desktop? Double-click **preview.cmd** or **preview.command** instead and use `build/atlantis-twine.html`, which includes your own unsaved changes.
2. In Twine, use **Library > Import** and pick the downloaded file. If Twine already has the story from last time, replace it.
3. Edit in Twine as usual.
4. Choose **Build > Export As Twee** and save the file into the repo folder (the one with `preview.cmd` in it).
5. Double-click **import-from-twine.cmd** (Windows) or **import-from-twine.command** (Mac; the first time, right-click it and choose **Open**). It puts every passage back into the right file and rebuilds the game.
6. Read the summary it shows: which passages were updated, added and removed. Then commit and push in GitHub Desktop.

New passages you create in Twine go into `src/new-passages.twee`. That's fine to leave, or you can move them into the right file later. Passages you deleted in Twine are deleted from the files too, and a passage you renamed counts as deleted plus new. A copy of the old files is kept in the `.backup` folder, which is not shared.

## How the story files work

- **Where things live:** `src/acts/act-1.twee` to `act-4.twee` hold each act's hub and locations. `src/characters/<name>.twee` holds each character's scenes and their Codex entry. `src/endings.twee` holds the endings.
- **Passages:** each scene starts with a line beginning with two colons and its name, like `:: A1 Castella`. Everything below it, up to the next `::` line, is that scene. Don't rename a passage unless you also update the links to it.
- **Links:** `[[Back to Act 1|Act 1]]` shows the words "Back to Act 1" and goes to the passage named "Act 1". `[[Act 1]]` alone uses the name as the words.
- **Tags:** the words in square brackets after a passage name, like `[character act1 todo]`. Remove `todo` when a scene is written. Keep the `act1` to `act4` tags, because they choose the music.
- **Notes to yourself:** text between `/*` and `*/` is hidden from players.
- **Adding a portrait:** put the picture in `assets/img` (a lowercase name like `castella.jpg`), then add this line directly under the passage's `::` line:
  `<img class="portrait" src="img/castella.jpg" alt="Castella">`
  For a wide banner instead, use `class="art"`.

## If something breaks

The playtest site keeps the last version that worked, so a mistake never takes it down. The Actions tab, or the preview window, shows the file and line with the problem. If you're stuck, ask for help in the team chat. Every change is saved in history, so anything can be undone.
