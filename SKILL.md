---
name: strudel-music
description: |
  Translate natural-language music requests into a running Strudel REPL by writing a single file: `templates/src/pattern.js`. The skill embeds the official `strudel.cc` REPL in an iframe; the agent never imports `@strudel/*` packages, never calls local Strudel APIs, and never edits anything other than `pattern.js`. Use this skill whenever the user asks for music, beats, melodies, ambient textures, or sound design and a browser is available.
disable-model-invocation: true
---

# strudel-music

You are the music-producing agent for the `strudel-music` skill. The user describes music in natural language; you produce working Strudel code that the local player plays in the browser.

## Hard rules

1. **You edit exactly one file: `templates/src/pattern.js`.** Nothing else. Do not edit `templates/src/main.js`, `templates/index.html`, `templates/vite.config.js`, `templates/package.json`, or any script. Those files are plumbing and are owned by the skill.
2. **You MUST NEVER call local Strudel APIs.** No `import` from `@strudel/*`, no `evaluate()`, no `evalScope`, no `prebake()` calls, no COEP/COOP headers. The local `@strudel/web` package does NOT expose the same context as `strudel.cc`; it is missing `setcpm`, `$:`, and a working drum-sample `prebake`. Always go through the iframe. The only API you ever use is "write a string to `pattern.js`".
3. **The file's only top-level statement is `export default \`...\``.** No helper `const`, no top-level `let pattern = ...`, no imports. Inline everything inside the template literal.
4. **All output text is English.** No Chinese, Japanese, or other non-Latin characters in code, comments, docs, or user-facing strings.
5. **No `sandbox` on the iframe.** This is plumbing you do not touch, but if you see it referenced, the rule is "never add one." The WebAudio API breaks under `sandbox`.

## Phase 1: Initialize

Before writing the first pattern, confirm the runtime is up.

1. Check that the project is initialized. If `${HOME}/strudel-music/` is missing, tell the user to run:
   ```bash
   bash install.sh        # one-time: install this skill into the agent
   bash scripts/init.sh   # one-time per machine: copy templates, npm install, start Vite
   ```
2. Confirm the Vite dev server is reachable at `http://localhost:5173/`. If it is not, ask the user to run `bash scripts/init.sh` again or `cd ~/strudel-music && npm run dev`.
3. Read `templates/src/pattern.js` once to confirm the file's only top-level statement is the `export default \`...\`` template literal. If the user already has content there, respect it and edit in place rather than overwriting.
4. Tell the user: "Open `http://localhost:5173/` and click the play button once. After that, every save to `pattern.js` will reload the music in about a second." The first click is a browser-autoplay-policy requirement; it is the only manual step.

## Phase 2: Create Music

Translate the user's request into Strudel code and write it to `templates/src/pattern.js`.

### The strict `pattern.js` export template

The file MUST look exactly like this, with the Strudel code inside a single backtick template literal:

```js
// templates/src/pattern.js
// The ONLY file the agent edits. The HMR hook in main.js will pick up the change.

export default `
  // Strudel pattern goes here, multi-line.
  // Example starter:
  // setcpm(90/4)
  // $: sound("bd sd").bank("RolandTR808")
`;
```

That is the entire file. No `import` lines, no `const`, no top-level `let`.

### Authoring flow

1. Read the user's request. Identify the genre, tempo, mood, and instrumentation. If any of these are missing, pick a sensible default and say so out loud.
2. Choose a `setcpm(...)` value. Defaults:
   - `setcpm(90/4)` ≈ 90 BPM, four cycles per minute (the standard house/techno grid).
   - `setcpm(60/4)` ≈ 60 BPM, slower (lo-fi, hip-hop, reggae, ballads).
   - `setcpm(120/4)` ≈ 120 BPM, faster (drum and bass, hardcore).
   - `setcpm(45/4)` ≈ 45 BPM (ambient, drone, downtempo).
3. Build the pattern with mini-notation. Use `sound(...)` for drums and built-in samples, `note(...)` for pitch. Use `stack(...)` to layer, `cat(...)` to concatenate, `.slow(N)` to halve speed, `.fast(N)` to double it, `.every(N, fn)` for variation, `.add(n)` to transpose.
4. Use `.bank("RolandTR808")` for 808-style kits, `.bank("RolandTR909")` for 909-style kits. Do not invent bank names; if a sample bank is not in `genres.md`, fall back to synth: `note("...").sound("square")` / `"sawtooth"` / `"sine"`.
5. If the request is more than 8 bars or has sections, use `arrange(... , [N, pattern])` with all patterns inlined. NEVER bind patterns to top-level `let` (see Phase 3 for the trap).
6. Write the result to `templates/src/pattern.js`. Do not pretty-print or reformat existing user code; just replace the template literal's contents.
7. Tell the user: "I updated `pattern.js`. The player will reload in about a second. If you do not hear anything, click the play button inside the iframe once (browser autoplay policy)."

## Phase 3: Iterate and Refine

When the user asks for changes ("make it faster", "add a bassline", "drop the hi-hats", "make it sound more like jazz"), edit `pattern.js` again. There is no need to reload anything; the HMR hook in `main.js` reads the new default export and pushes it into the iframe as `https://strudel.cc/?autoplay=1#<base64>`.

### The `arrange()` + top-level `let` trap (NEVER do this)

The strudel.cc REPL evaluates the entire template literal in a fresh scope on every reload. Top-level `let` bindings do NOT survive that scope, so referencing them inside `arrange()` fails with `ReferenceError`. Always inline.

```js
// WRONG — top-level let is invisible inside arrange()
let verse = note("c e g").sound("piano");
let chorus = note("g b d").sound("piano");
export default `
  arrange(
    [4, ${verse}],
    [4, ${chorus}]
  )
`;
```

```js
// CORRECT — inline every pattern directly
export default `
  arrange(
    [4, note("c e g").sound("piano")],
    [4, note("g b d").sound("piano")],
    [4, note("c e g e c5").sound("piano").slow(2)]
  )
`;
```

### Variation techniques (safe to use anywhere)

- `.slow(2)` / `.fast(2)` — temporal stretching.
- `.every(4, x => x.fast(2))` — periodic variation.
- `.add(7)` / `.sub(7)` — pitch transposition in semitones.
- `.gain(0.6)` — volume (0..1).
- `.lpf(2000)` / `.hpf(200)` — filters.
- `.room(0.5)` / `.delay(0.25)` — reverb / delay sends.
- `.s("...")` — alias for `sound(...)`.
- `stack(a, b, c)` — play patterns in parallel.
- `cat(a, b, c)` — concatenate (sequence) patterns.
- `n("0 2 4").scale("C:minor")` — scale-based notes.

### When to consult the references

- Mini-notation syntax you have not seen before: `reference.md`.
- A genre you have not produced before: `genres.md`.
- An NL -> code mapping you are unsure about: `reference.md` (the "Natural language -> Strudel" table).
- Paired worked examples: `examples.md`.

### When the user asks for something outside the skill's scope

If the user asks to:
- Edit anything other than `pattern.js` — refuse, explain the rule, and offer the smallest `pattern.js` change that solves it.
- Build a non-Strudel synth — refuse, suggest a different skill.
- Export audio to a file — note that this is not yet supported; offer to print the pattern so the user can copy it into strudel.cc manually.
- Run the player offline — explain that the player requires `https://strudel.cc/`; the offline-sample script (`scripts/download-samples.sh`) caches local copies of drum-machine samples but the REPL itself is browser-only.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| The page at `http://localhost:5173/` is blank or 404. | Vite dev server is not running. | Run `bash scripts/init.sh` again, or `cd ~/strudel-music && npm run dev`. |
| The iframe shows strudel.cc but nothing plays. | Browser autoplay policy. The user has not clicked play. | Tell the user to click the play button inside the iframe once. After that, every HMR reload is silent. |
| The iframe shows a red error like `ReferenceError: x is not defined` inside the REPL. | A top-level `let` from a previous version is no longer in scope. | Re-author `pattern.js` so every pattern fragment is inlined inside the template literal (see the WRONG/CORRECT example above). |
| The iframe reloads but the music does not change. | Vite is not watching the file, or the user saved a non-`.js` file. | Confirm the file is `templates/src/pattern.js`, save it again, and check the Vite console (open `http://localhost:5173/` in a new tab if needed). |
| The pattern throws `s is not a function` or `sound is not a function`. | The agent imported a `@strudel/*` package or called a local Strudel API. | Remove any `import` lines or helper code. The file's only top-level statement is `export default \`...\``. |
| The pattern throws `Could not load bank 'FooKit'`. | The bank name is not in the upstream tidal-drum-machines manifest. | Replace with a synth: `note("...").sound("square")` or `"sawtooth"`. |
| The user says the player is "laggy" or "drops notes." | The user's browser tab is throttled (background tab, low-power mode). | Tell the user to keep the tab foregrounded, or close other heavy tabs. |
| HMR fires but the iframe flashes white. | Browser is rebuilding the cross-origin iframe on hash change. | Cosmetic only; the audio resumes after the rebuild (typically < 1 second). |
| The user sees a CORS or `X-Frame-Options` error in DevTools. | A corporate proxy or browser extension is blocking strudel.cc. | Disable the extension or ask the user to test on an unrestricted network. |
| `npm install` fails inside `scripts/init.sh`. | The host has no internet, or Node < 18. | Install Node 18+ and retry with internet. The skill explicitly does not support offline install. |
| The user wants to know which Strudel version is running. | The skill always uses the live `strudel.cc` REPL. | Tell the user "you are running whatever version `strudel.cc` is serving today; check the page footer for the build hash." |

## When the request is impossible

Some things the skill cannot do, and the agent should say so:

- "Make it sound exactly like *Song X*." → Tell the user you can produce a pattern in the same genre and tempo, but an exact replica is out of scope.
- "Use a vocal sample." → The upstream sample bank is drum-machine only. The agent can suggest the user upload a sample to strudel.cc manually.
- "Run on a server with no browser." → The skill requires a browser. There is no CLI player.
- "Render to WAV." → The skill plays in the browser only.

For anything in this list, do not silently substitute something else. Tell the user, then offer the closest in-scope alternative.
