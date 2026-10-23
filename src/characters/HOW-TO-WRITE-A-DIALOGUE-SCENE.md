# How the Act 1 "Example Scene" was made

A step-by-step guide for writers. No coding background needed.

The Example Scene is the Castella conversation you reach from the main menu (**Example scene: Talk to Castella**) or from **Act 1 > Example scene** on the playtest site. Its source is `src/characters/castella.twee`, starting at the passage `A1 Castella Talk`. Castella says one line at a time, each line fades in, you click a reply, and her next lines fade in under it.

The short version: **the hard part is already built.** Someone set up four reusable building blocks (`say`, `stage`, `choices`, `reply`). Writing a scene is just filling those in with your lines, one small passage per "beat" of the conversation.

---

## Before you start: why it might not have worked for you

The building blocks live inside the project's story. If you start a **brand new story** in Twine and paste the scene in, it will show red error boxes, because the new story doesn't have the building blocks.

So always write inside the project's story (see `HOW-TO-EDIT.md` in the repo for the full setup):

1. **Editing the text files:** open `src/characters/<name>.twee` and add your passages there. Double-click `preview.cmd` (Windows) or `preview.command` (Mac) to see the game.
2. **Using the Twine editor:** click **Download for Twine** in the playtest site's left sidebar, then use **Library > Import** in Twine. When you're done, export as Twee and run `import-from-twine`, as `HOW-TO-EDIT.md` explains.
3. Either way, check that the passages **Dialogue Widgets**, **Dialogue Stylesheet** and **TrustWidget** are there. Don't edit them.

---

## Step 1. Make the "scene" passage

This is the passage the player lands on. It sets the stage and opens the conversation box. Here is Castella's (from `src/characters/castella.twee`):

```
:: A1 Castella Talk [character act1 char-Castella]
!First Research Station
//Act 1, Sir Richard Black's first research station//

<<set _dlgWho to "Castella">>
<div id="dlg"><<include "A1 Castella Talk 1">></div>
```

What each line means:

| Line | In plain words |
|---|---|
| `:: A1 Castella Talk` | The passage's name. In the Twine editor, this is just the title box; you don't type the `::`. |
| `[character act1 char-Castella]` | Tags, like sticky labels. They help us sort passages. In Twine, type them in the tag box. |
| `!First Research Station` | A big heading. One `!` = big, `!!` = smaller. |
| `//Act 1, ...//` | Italic text. Two slashes on each side. |
| `<<set _dlgWho to "Castella">>` | Tells the scene who you're talking to, so replies can raise or lower *her* trust. Spell the name exactly as it appears in the trust list in `StoryInit`. |
| `<div id="dlg">` ... `</div>` | Opens and closes the conversation box. Every line of the conversation goes inside this box. Copy it exactly. |
| `<<include "A1 Castella Talk 1">>` | "Show the first beat here." The name in quotes must match the first beat's passage name exactly. |

## Step 2. Write the first beat

A **beat** is one chunk of the conversation: what the NPC says and does, then the player's choices. Each beat is its own passage. Here is Castella's first beat:

```
:: A1 Castella Talk 1 [dialogue act1 char-Castella]
<<stage "Crates of waterlogged notebooks are stacked to the ceiling. A young jellyfolk woman in a bubble helmet and a healer's coat sits among them, hands clasped tight in her lap. She looks up at you with tired eyes.">>
<<say "Castella" "Hmmm… You're not one of the King's guards. And you're certainly not Richard." "wary">>
<<say "Castella" "So who let you in here?">>
<<choices>>
<<reply "I'm a friend of Richard's. I came down to find him." "A1 Castella Talk 2a" 5>>
<<reply "The door was open." "A1 Castella Talk 2b" -5>>
<</choices>>
```

The four building blocks:

**`<<stage "...">>`** is a description or action, like a stage direction in a script. It shows in grey italics.

**`<<say "Name" "Line">>`** is one line of NPC dialogue. First the speaker's name, then what they say.
- You can add a third bit for mood: `<<say "Castella" "Line" "wary">>` shows *(wary)* next to the line. It's optional.
- Each `say` or `stage` fades in a moment after the one before it. That's the whole "one line at a time" effect. You don't have to do anything extra.

**`<<choices>>` ... `<</choices>>`** is the box of reply buttons. It opens with `<<choices>>` and closes with `<</choices>>` (note the extra `/`). Put your replies between them.

**`<<reply "What the MC says" "Next beat" 5>>`** is one clickable reply.
- First: the words the player clicks. They also appear as the MC's line after clicking.
- Second: the name of the beat passage that comes next.
- Third (optional): how much trust changes. `5` raises it by 5, `-5` lowers it by 5. Leave it off for no change.

**Rules for the quotes:** every piece goes in "double quotes". Apostrophes inside a line are fine (`You're`). If a character needs to quote someone, use single quotes or curly quotes ( “ ” ) inside the line, not straight double quotes, or the line will break.

## Step 3. Write the next beats

Make a new passage for each beat a reply points to. Its name must match the reply's second bit **exactly** (same capitals, same spaces). Castella's scene has these beats:

```
Talk 1  ──>  Talk 2a  ──┐
        └─>  Talk 2b  ──┴──>  Talk 3 or 3b  ──>  Talk 4  ──>  5a / 5b / 5c  ──>  Talk 7 (ending)
```

Two tricks keep the number of passages small:

- **Branches can meet up again.** Both Talk 2a and Talk 2b have replies that point to the same Talk 3. You don't need a whole separate story for every choice.
- **Reusing a beat.** Talk 6 says one line and then has `<<include "A1 Castella Talk 7">>`, which means "now also show everything from Talk 7". Handy, but you can skip it and just point a reply to Talk 7.

## Step 4. Write the last beat

A beat with **no `<<choices>>`** ends the conversation. Put normal links at the bottom so the player can leave:

```
:: A1 Castella Talk 7 [dialogue act1 char-Castella]
<<say "Castella" "There's an inventor out in the Wilds. Sabelle. If anyone can build Richard's machine, it's them.">>
<<say "Castella" "Go on, then. Find out what the scientists in District 1 know. I'll keep digging here.">>

[[Back to First Research Station|A1 First Research Station]]
[[Back to Act 1|Act 1]]
```

`[[Words to show|Passage name]]` is a normal link. The part before the `|` is what the player sees, the part after is where it goes.

(The real Castella ending also has a fade-in box showing her final trust number. That part is fancy, and you can leave it out. Without it, the links just appear a moment before the last lines finish fading in.)

## Step 5. Link to your scene

Nobody can reach the scene until something links to it. Castella's was added to the Act 1 hub (`src/acts/act-1.twee`):

```
!!Example scene
* [[Talk to Castella (click-through dialogue)|A1 Castella Talk]]
```

The `*` makes a bullet point. Link to the **scene** passage from Step 1, not to beat 1.

## Step 6. Test it

Double-click `preview.cmd` / `preview.command`, or click **Play** in Twine. Go to your link, and click through every reply. Look for:

- **A red box** = a typo. Usually a missing quote, a missing `>>`, or a missing `<</choices>>`.
- **"Error: the passage ... does not exist"** = a reply's next-beat name doesn't match a passage name exactly.
- **Trust shows NaN** = the name in `_dlgWho` isn't in the trust list in `StoryInit`. Add your character there, or check the spelling.

---

## What you can drop to keep it simple

You don't need everything Castella's scene uses. All of these are optional:

| Can drop | What happens without it |
|---|---|
| The mood (third bit of `say`) | No *(wary)* label. |
| `<<stage>>` lines | Only spoken dialogue. |
| The trust number on `reply` | Replies don't change trust. If **none** of your replies use a number, you can also drop the `<<set _dlgWho ...>>` line. |
| Branching | Give each beat a single reply. It plays like a click-to-continue cutscene. |
| `<<include>>` inside a beat (the Talk 6 trick) | Point replies straight to the next beat instead. |
| The fancy ending box | Use plain links at the end (as in Step 4). |
| Tags and `{"position":...}` | Only matter for sorting and the map layout in Twine. Twine adds the position by itself. |
| `/* ... */` notes | Hidden comments for other writers. The player never sees them. |
| `<<set _dlgT to -0.7>>` and the `\` at line ends | Timing and spacing details. The building blocks work fine without them. |

What you **can't** drop: the `<div id="dlg">...</div>` box with the `<<include>>` of beat 1, and the `<<choices>>` / `<</choices>>` pair around replies.

---

## Copy-paste starter

Three passages: the scene, one beat with a choice, and an ending. Replace `Pearl`, the passage names and the lines with your own. Keep the passage names matching.

If you use the Twine editor, make one passage per `::` block: put the name in the title box, the tags in the tag box, and paste only the lines **below** the `::` line.

```
:: A1 Pearl Talk [character act1]
!Pearl's Store
//Act 1//

<<set _dlgWho to "Pearl">>
<div id="dlg"><<include "A1 Pearl Talk 1">></div>


:: A1 Pearl Talk 1 [dialogue act1]
<<stage "Describe what the player sees when they walk in.">>
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

Then add a link to it somewhere, for example in the Act 1 hub:

```
* [[Talk to Pearl|A1 Pearl Talk]]
```

To grow it, add more beats: copy the `A1 Pearl Talk 1` passage, give it a new name (`A1 Pearl Talk 3`), and point a reply at it.

For other markup (bold, links, if/else), see the markup cheat sheet.
