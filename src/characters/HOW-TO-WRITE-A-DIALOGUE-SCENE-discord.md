# Dialogue scene guide: Discord version

The same guide as HOW-TO-WRITE-A-DIALOGUE-SCENE.md, split into 7 messages that each fit Discord's 2000-character limit. Copy everything between one ✂️ line and the next, and post the messages in order.

✂️ ---------- Message 1 of 7 ----------

# How the Act 1 Example Scene was made (1/7)
A step-by-step guide for writers. No coding needed.

The Example Scene is the Castella conversation on the main menu (**Example scene: Talk to Castella**). She says one line at a time, each line fades in, you click a reply, and her next lines fade in below it.

**The hard part is already built.** There are four reusable building blocks: `say`, `stage`, `choices` and `reply`. Writing a scene just means filling them in with your lines, one small passage per "beat" of the conversation.

## Before you start: why it might not work
The building blocks only exist inside the **project's** story. If you paste the scene into a brand new Twine story, you'll get red error boxes.

So always write inside the project's story:
1. **Text files:** add your passages to `src/characters/<name>.twee` and double-click `preview.cmd` / `preview.command` to see them.
2. **Twine editor:** click **Download for Twine** in the site's sidebar, then **Library > Import**. Bring changes back with `import-from-twine` (see `HOW-TO-EDIT.md`).
3. Check that the passages **Dialogue Widgets**, **Dialogue Stylesheet** and **TrustWidget** are there. Don't edit them.

✂️ ---------- Message 2 of 7 ----------

## Step 1: Make the "scene" passage (2/7)
This is where the player lands. It opens the conversation box and shows the first beat.
```
:: A1 Castella Talk [character act1]
!First Research Station
//Act 1//

<<set _dlgWho to "Castella">>
<div id="dlg"><<include "A1 Castella Talk 1">></div>
```
What each line means:
- `:: A1 Castella Talk` is the passage name. In the Twine editor, that's the title box. You don't type the `::`.
- `[character act1]` are tags (sorting labels). In Twine, put them in the tag box.
- `!First Research Station` is a big heading. `!!` makes a smaller one.
- `//Act 1//` makes italics.
- `<<set _dlgWho to "Castella">>` says who you're talking to, so replies can change *her* trust. Spell the name exactly as in the trust list in `StoryInit`.
- `<div id="dlg">` ... `</div>` is the conversation box. Everything in the conversation goes inside it. Copy it exactly.
- `<<include "A1 Castella Talk 1">>` means "show the first beat here". The name must match the beat's passage name exactly.

✂️ ---------- Message 3 of 7 ----------

## Step 2: Write the first beat (3/7)
A **beat** is one chunk of conversation: what the NPC says and does, then the player's choices. Each beat is its own passage.
```
:: A1 Castella Talk 1 [dialogue act1]
<<stage "A tired young healer sits among crates of notebooks.">>
<<say "Castella" "Hmmm… You're not one of the King's guards." "wary">>
<<say "Castella" "So who let you in here?">>
<<choices>>
<<reply "I'm a friend of Richard's." "A1 Castella Talk 2a" 5>>
<<reply "The door was open." "A1 Castella Talk 2b" -5>>
<</choices>>
```
**`<<stage "...">>`** is a description or action, like a stage direction. It shows in grey italics.

**`<<say "Name" "Line">>`** is one NPC line. An optional third bit adds a mood label, like *(wary)*. Each `say` and `stage` fades in a moment after the last one. That's the whole "one line at a time" effect, and it happens automatically.

**`<<choices>>` ... `<</choices>>`** is the box of reply buttons. Note the extra `/` on the closing one.

**`<<reply "MC's words" "Next beat" 5>>`** is one clickable reply: the words the player clicks, the name of the next beat passage, and (optional) a trust change. `5` adds 5, `-5` takes 5 away.

⚠️ Put every piece in "double quotes". Apostrophes are fine. If a line needs quote marks inside it, use 'single' or “curly” quotes.

✂️ ---------- Message 4 of 7 ----------

## Step 3: Write the next beats (4/7)
Make a new passage for every beat a reply points to. Its name must match the reply **exactly** (same capitals and spaces).

Castella's scene goes: Talk 1 → 2a or 2b → 3 or 3b → 4 → 5a, 5b or 5c → 7 (the end)

Two tricks keep it short:
- **Branches can meet again.** Replies in both 2a and 2b point to the same Talk 3. You don't need a separate story for every choice.
- **Reusing a beat.** Talk 6 ends with `<<include "A1 Castella Talk 7">>`, which shows Talk 7 too. Optional. You can just point a reply at Talk 7.

## Step 4: Write the last beat
A beat with **no** `<<choices>>` ends the conversation. Add normal links so the player can leave:
```
:: A1 Castella Talk 7 [dialogue act1]
<<say "Castella" "There's an inventor out in the Wilds. Sabelle.">>
<<say "Castella" "Go on, then. I'll keep digging here.">>

[[Back to Act 1|Act 1]]
```
`[[Words to show|Passage name]]` is a link: the text before the `|` is what the player sees, and the text after it is where it goes.

✂️ ---------- Message 5 of 7 ----------

## Step 5: Link to your scene (5/7)
Nobody can reach your scene until something links to it. Castella's is in the Act 1 hub:
```
!!Example scene
* [[Talk to Castella|A1 Castella Talk]]
```
`*` makes a bullet point. Link to the **scene** passage from Step 1, not to beat 1.

## Step 6: Test it
Double-click `preview.cmd` / `preview.command` (or click **Play** in Twine), find your link, and click through every reply.
- 🟥 **Red box:** a typo. Usually a missing quote, a missing `>>`, or a missing `<</choices>>`.
- **"passage does not exist":** a reply's next-beat name doesn't match a passage name.
- **Trust shows NaN:** the name in `_dlgWho` isn't in the trust list in `StoryInit`. Add the character there or fix the spelling.

✂️ ---------- Message 6 of 7 ----------

## What you can leave out (6/7)
Castella's scene uses extras you don't need. All of these are optional:
- **Mood** (the third bit of `say`): no *(wary)* label.
- **`<<stage>>` lines**: dialogue only.
- **Trust numbers on `reply`**: replies don't change trust. If no reply has a number, you can drop the `<<set _dlgWho ...>>` line too.
- **Branching**: give each beat one reply, and it plays like a click-to-continue cutscene.
- **`<<include>>` inside a beat**: point replies straight at the next beat.
- **The fancy ending box** in the real Castella scene, which shows her final trust: plain links work fine.
- **Tags and `{"position":...}`**: these only help with sorting and the map in Twine.
- **`/* ... */`**: hidden notes for other writers.
- **`<<set _dlgT to -0.7>>` and `\` at line ends**: timing and spacing details.

**You can't leave out** the `<div id="dlg">...</div>` box with the `<<include>>` of beat 1, or the `<<choices>>` / `<</choices>>` pair around replies.

✂️ ---------- Message 7 of 7 ----------

## Copy-paste starter (7/7)
Three passages: the scene, one beat with a choice, and an ending. Swap in your character, passage names and lines. In Twine, make one passage per `::` block. The name goes in the title box, tags go in the tag box, and you paste only the lines **below** the `::` line.
```
:: A1 Pearl Talk [character act1]
!Pearl's Store
//Act 1//

<<set _dlgWho to "Pearl">>
<div id="dlg"><<include "A1 Pearl Talk 1">></div>


:: A1 Pearl Talk 1 [dialogue act1]
<<stage "Describe what the player sees.">>
<<say "Pearl" "First thing Pearl says." "cheerful">>
<<say "Pearl" "Second thing Pearl says.">>
<<choices>>
<<reply "A friendly answer." "A1 Pearl Talk 2" 5>>
<<reply "A rude answer." "A1 Pearl Talk 2" -5>>
<</choices>>


:: A1 Pearl Talk 2 [dialogue act1]
<<say "Pearl" "Pearl's last line.">>

[[Back to Act 1|Act 1]]
```
Then link to it from a hub: `* [[Talk to Pearl|A1 Pearl Talk]]`

To make it longer, copy the `A1 Pearl Talk 1` passage, give it a new name like `A1 Pearl Talk 3`, and point a reply at it.
