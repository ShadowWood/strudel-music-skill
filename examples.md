# Strudel Examples

This file is the agent's cookbook: 16 paired **natural-language prompt ->
working `pattern.js`** examples, ordered roughly from simple one-shot
patterns to a full multi-section song.

> **Reminder:** every example below replaces the **whole** template
> literal in `templates/src/pattern.js`. The file's only top-level
> statement stays `export default \`...\``. Never add `let` or `const`
> outside the template literal, and never import from `@strudel/*`.

---

## Table of contents

- [Example 1 — "Give me a simple four-on-the-floor kick at 120 BPM"](#example-1--give-me-a-simple-four-on-the-floor-kick-at-120-bpm)
- [Example 2 — "Add an off-beat clap and some hi-hats"](#example-2--add-an-off-beat-clap-and-some-hi-hats)
- [Example 3 — "A slow ambient drone in C minor"](#example-3--a-slow-ambient-drone-in-c-minor)
- [Example 4 — "A jazzy ii-V-I-vi in C with piano"](#example-4--a-jazzy-ii-v-i-vi-in-c-with-piano)
- [Example 5 — "Lo-fi boom-bap at 70 BPM"](#example-5--lo-fi-boom-bap-at-70-bpm)
- [Example 6 — "Drum and bass break at 174 BPM"](#example-6--drum-and-bass-break-at-174-bpm)
- [Example 7 — "A trap hi-hat pattern with rolls every other bar"](#example-7--a-trap-hi-hat-pattern-with-rolls-every-other-bar)
- [Example 8 — "An arpeggio on a Cmaj7 chord"](#example-8--an-arpeggio-on-a-cmaj7-chord)
- [Example 9 — "Take it down an octave and add a sub-bass"](#example-9--take-it-down-an-octave-and-add-a-sub-bass)
- [Example 10 — "Shuffle the hi-hats"](#example-10--shuffle-the-hi-hats)
- [Example 11 — "Add some reverb and delay to the melody"](#example-11--add-some-reverb-and-delay-to-the-melody)
- [Example 12 — "A bossa nova clave with nylon guitar"](#example-12--a-bossa-nova-clave-with-nylon-guitar)
- [Example 13 — "Reggae one-drop with a skank guitar"](#example-13--reggae-one-drop-with-a-skank-guitar)
- [Example 14 — "Switch the drums to the RolandTR808 bank"](#example-14--switch-the-drums-to-the-rolandtr808-bank)
- [Example 15 — "A simple breakbeat with a fill at the end"](#example-15--a-simple-breakbeat-with-a-fill-at-the-end)
- [Example 16 — "A full pop song: intro / verse / chorus / bridge / outro"](#example-16--a-full-pop-song-intro--verse--chorus--bridge--outro)

---

### Example 1 — "Give me a simple four-on-the-floor kick at 120 BPM"

**You ask:**

> "I just need a kick on every beat at 120 BPM. Nothing else."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(120/4)
  $: sound("bd*4").bank("RolandTR909")
`;
```

**Why this works:**

- `setcpm(120/4)` is 120 BPM on the standard 4-step grid.
- `sound("bd*4")` plays the kick sample four times per cycle (one per beat).
- `.bank("RolandTR909")` is the canonical 909 house/techno kit.

---

### Example 2 — "Add an off-beat clap and some hi-hats"

**You ask:**

> "On top of the kick, put a clap on 2 and 4, and some quiet hi-hats on every 8th note."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(120/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.8),
    sound("hh*8").bank("RolandTR909").gain(0.3)
  )
`;
```

**Why this works:**

- `stack(...)` layers patterns in parallel (same as a comma-separated
  mini-notation string, but easier to read when each layer has its own
  modifier chain).
- `~ cp ~ cp` puts the clap on beats 2 and 4 (the backbeat).
- `hh*8` plays the hi-hat on every 8th note, with `.gain(0.3)` keeping
  it under the kick and clap.

---

### Example 3 — "A slow ambient drone in C minor"

**You ask:**

> "Make it really slow and dreamy — just a long C-minor chord that just sits there."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(40/4)
  $: stack(
    note("c3 eb3 g3").sound("sawtooth").slow(8).lpf(800).room(0.8).gain(0.3),
    note("c2").sound("sine").slow(8).gain(0.4)
  )
`;
```

**Why this works:**

- `setcpm(40/4)` is roughly 40 BPM, the downtempo / ambient range.
- The chord `c3 eb3 g3` is a C minor triad in close root position.
- `.slow(8)` stretches each note over many seconds, so the chord
  evolves slowly.
- `.lpf(800)` rolls off the high end to remove the saw-wave's bite.
- `.room(0.8)` puts the texture in a large reverb space.
- The `sine` layer is a sub-bass drone one octave below the chord.

---

### Example 4 — "A jazzy ii-V-I-vi in C with piano"

**You ask:**

> "Play a jazzy chord progression — Dm7, G7, Cmaj7, Am7 — with a piano sound and some walking bass."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(110/4)
  $: stack(
    chord("<Dm7 G7 Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4),
    note("<d2 c2 b1 a1>").sound("bass").gain(0.7),
    sound("~ hh ~ hh ~ hh ~ hh").bank("RolandTR909").gain(0.2).room(0.3)
  )
`;
```

**Why this works:**

- `chord("<Dm7 G7 Cmaj7 Am7>")` cycles through the four chords, one per
  cycle. `< ... >` is the choose-within-cycle operator; the chords
  progress at one chord per cycle.
- `.voicings("lefthand")` keeps the piano voicing in a comfortable
  two-hand range, with sensible inversions.
- The bass line `d2 c2 b1 a1` descends through the roots of the chords,
  one per cycle (a classic walking-bass feel).
- `sound("~ hh ~ hh ~ hh ~ hh")` puts brushed-style hi-hats on the
  off-beats, with `.room(0.3)` to soften them.

---

### Example 5 — "Lo-fi boom-bap at 70 BPM"

**You ask:**

> "Make it sound like a 90s hip-hop beat — boom-bap drums, a dusty piano loop, around 70 BPM."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(70/4)
  $: stack(
    sound("bd ~ sd ~").bank("RolandTR808").gain(0.7).lpf(300),
    sound("hh*4").bank("RolandTR808").gain(0.3).lpf(800).room(0.3),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").room(0.5).gain(0.4)
  )
`;
```

**Why this works:**

- `bd ~ sd ~` is the classic boom-bap kick-snare back-and-forth.
- `.lpf(300)` on the kick and `.lpf(800)` on the hats strip the high
  end off, which is the "dusty" lo-fi signature.
- `setcpm(70/4)` puts the tempo right in the lo-fi sweet spot
  (65-80 BPM).
- The piano plays the I-vi-ii-V in C major at one chord per cycle.

---

### Example 6 — "Drum and bass break at 174 BPM"

**You ask:**

> "Give me a fast drum-and-bass break — 174 BPM, rolling bass, snappy snare."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(87/2)
  $: stack(
    sound("[bd sd] [sd bd] [bd sd] [~ sd]").bank("RolandTR808").gain(0.95),
    sound("hh*16").bank("RolandTR808").gain(0.3).every(2, x => x.fast(2)),
    note("<c1 c1 eb1 g1 c2>").sound("sawtooth").lpf(1200).gain(0.6)
  )
`;
```

**Why this works:**

- `setcpm(87/2)` sets the cycle to two steps, so a 4-event pattern
  plays at 87*2 = 174 BPM — the canonical DnB tempo.
- The drum break `[bd sd] [sd bd] [bd sd] [~ sd]` is an irregular
  Amen-style pattern.
- `hh*16` rolls the hi-hats at 16 steps per cycle, with a `.fast(2)`
  accent on every other cycle for the classic DnB "switch-up" feel.
- The bassline `c1 c1 eb1 g1 c2` is a rolling riff that sits in
  the C minor tonality, low-passed at 1200 Hz to leave room for the
  break.

---

### Example 7 — "A trap hi-hat pattern with rolls every other bar"

**You ask:**

> "I want trap-style hi-hats: 8 hits per bar, and then a fast triplet roll every other bar."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(140/4)
  $: stack(
    sound("bd*4").bank("RolandTR808").gain(0.95),
    sound("~ ~ sd ~").bank("RolandTR808").gain(0.7),
    sound("hh*8").bank("RolandTR808").gain(0.4).every(2, x => x.fast(2))
  )
`;
```

**Why this works:**

- `setcpm(140/4)` sets the tempo to 140 BPM, the trap default.
- `hh*8` plays 8 hi-hat hits per cycle (one per 8th note).
- `.every(2, x => x.fast(2))` applies a `.fast(2)` to the hi-hats
  every other cycle, doubling the hat density to create the
  signature triplet-roll feel.
- The kick (`bd*4`) and snare (`~ ~ sd ~`) form a simple trap
  backbone.

---

### Example 8 — "An arpeggio on a Cmaj7 chord"

**You ask:**

> "Just play the notes of a Cmaj7 chord as an arpeggio, going up and down."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(100/4)
  $: chord("Cmaj7")
    .arp("updown")
    .sound("piano")
    .room(0.4)
    .gain(0.6)
`;
```

**Why this works:**

- `chord("Cmaj7")` defines the chord; `.arp("updown")` walks the
  chord tones up and down, one per step.
- `.sound("piano")` is the General MIDI piano patch — no sample bank
  required.
- `.room(0.4)` adds a moderate reverb for a "studio" feel.
- The single source (no `stack`) means the arpeggio plays alone,
  with no drums or other layers.

---

### Example 9 — "Take it down an octave and add a sub-bass"

**You ask:**

> "I have a chord progression in C major. Make it sound heavier — drop the chord an octave and add a sub-bass one octave below that."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(90/4)
  $: stack(
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").room(0.4).sub(12),
    note("<c1 c1 g0 f1>").sound("sine").lpf(150).gain(0.9)
  )
`;
```

**Why this works:**

- `.sub(12)` on the piano voicing transposes the whole chord down by
  12 semitones (one octave).
- The `sine` layer plays the roots of the chord an octave below the
  piano voicing — pure low end, with `.lpf(150)` cutting anything
  above the sub-bass range.
- `note("c1 c1 g0 f1")` cycles through the roots: C, C, G, F. (The
  `g0` is a half-octave below C1; the voicing is fine because the
  `sine` has no audible pitch character at that range.)

---

### Example 10 — "Shuffle the hi-hats"

**You ask:**

> "The hi-hats sound too straight. Shuffle them."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(120/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
    sound("hh*8").bank("RolandTR909").swing(0.3).gain(0.4)
  )
`;
```

**Why this works:**

- `.swing(0.3)` pushes the off-beats back by 30%, giving the
  hi-hats a triplet-feel shuffle.
- The kick and clap are not swung, so only the hi-hats get the
  shuffle treatment — the standard "swing the hats" technique.

---

### Example 11 — "Add some reverb and delay to the melody"

**You ask:**

> "Play a simple C-E-G melody and put it in a big room with a quarter-note delay."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(100/4)
  $: note("c4 e4 g4 e4 c5")
    .sound("piano")
    .room(0.7)
    .delay(0.4)
    .delaytime(0.375)
    .delayfeedback(0.45)
    .gain(0.6)
`;
```

**Why this works:**

- `room(0.7)` is a large reverb send, putting the piano in a
  cathedral-sized space.
- `delay(0.4)` enables the delay send at 40% mix.
- `delaytime(0.375)` sets the delay time to a dotted 8th (in
  seconds) — close to a quarter note at this tempo.
- `delayfeedback(0.45)` lets each echo repeat several times before
  fading.

---

### Example 12 — "A bossa nova clave with nylon guitar"

**You ask:**

> "I want a bossa nova feel — that syncopated clave rhythm, with a soft nylon guitar and a piano."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(100/4)
  $: stack(
    sound("[~ cp] [hh ~] [~ ~ cp] [hh ~ cp]").bank("RolandTR808").gain(0.4),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("gm_nylon_guitar").gain(0.5).room(0.3),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").gain(0.3).delay(0.3)
  )
`;
```

**Why this works:**

- The pattern `[~ cp] [hh ~] [~ ~ cp] [hh ~ cp]` is a 16th-note
  bossa nova clave: the clap lands on the syncopated "and" of beats,
  with a hi-hat color.
- The `gm_nylon_guitar` voicing plays the chord changes with a warm
  nylon-string tone, the classic bossa nova timbre.
- The piano is the same progression, an octave higher, with a
  light delay for shimmer.

---

### Example 13 — "Reggae one-drop with a skank guitar"

**You ask:**

> "Play a reggae one-drop — kick and snare both on beat 3 — with a guitar that chucks on the off-beats."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(75/4)
  $: stack(
    sound("~ ~ bd ~").bank("RolandTR808").gain(0.95),
    sound("~ ~ sd ~").bank("RolandTR808").gain(0.7),
    sound("hh*8").bank("RolandTR808").gain(0.3),
    note("<c2 g2 c2 f2>").sound("gm_nylon_guitar").gain(0.55).room(0.3)
  )
`;
```

**Why this works:**

- `~ ~ bd ~` and `~ ~ sd ~` are the one-drop: both kick and snare
  hit on beat 3 of the bar, leaving beats 1, 2, and 4 silent.
- The `hh*8` keeps time across the bar with soft hi-hats.
- The `gm_nylon_guitar` plays a four-bar bass-note loop
  (`c2 g2 c2 f2`, one per cycle), which is the reggae "skank"
  bass pattern.

---

### Example 14 — "Switch the drums to the RolandTR808 bank"

**You ask:**

> "I'm using the RolandTR909 kit, but I want the warmer, hip-hop style 808 sound instead."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(120/4)
  $: stack(
    sound("bd*4").bank("RolandTR808").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR808").gain(0.8),
    sound("hh*8").bank("RolandTR808").gain(0.3)
  )
`;
```

**Why this works:**

- The pattern is unchanged from Example 2, but every `.bank(...)`
  call now uses `RolandTR808` instead of `RolandTR909`.
- The 808 kit has a rounder, deeper kick and a punchier clap than
  the 909 — ideal for hip-hop, trap, and slower house styles.

> **Caveat:** the 808 bank is only available after
> `scripts/download-samples.sh` has populated `${HOME}/strudel-music/public/samples/`.
> Before that, fall back to a built-in synth like `sound("square")`.

---

### Example 15 — "A simple breakbeat with a fill at the end"

**You ask:**

> "Play a four-on-the-floor kick with a snare on the backbeat, and a snare fill every 8 bars."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
export default `
  setcpm(124/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ sd ~ sd").bank("RolandTR909").every(8, x => x.fast(2)).gain(0.8)
  )
`;
```

**Why this works:**

- The kick plays four-on-the-floor.
- The snare plays the backbeat (`~ sd ~ sd`).
- `.every(8, x => x.fast(2))` doubles the snare speed every 8
  cycles, creating a quick snare fill right before the loop resets.
- This is the canonical "fill at the end of the 8-bar phrase"
  pattern.

---

### Example 16 — "A full pop song: intro / verse / chorus / bridge / outro"

This is the flagship example. It shows how to use `arrange(...)` to
string several patterns together into a full song structure. **Every
pattern is inlined directly inside the template literal** — there are
no top-level `let` or `const` bindings anywhere.

> **The trap this example demonstrates:** strudel.cc evaluates the
> entire template literal in a fresh scope on every reload. If you
> write `let verse = note("...");` above `export default \`...\``
> and then reference `${verse}` inside `arrange()`, the REPL raises
> `ReferenceError: verse is not defined`. The fix is to inline
> every pattern fragment directly, as this example does. See
> `reference.md` for the full `// WRONG` / `// CORRECT` walkthrough.

**You ask:**

> "Build me a full pop song: a 4-bar drum intro, a 16-bar verse, an 8-bar chorus, an 8-bar bridge, and a 4-bar outro. House-style drums at 124 BPM, with a synth lead that changes in each section."

**You write to `templates/src/pattern.js`:**

```js
// templates/src/pattern.js
// Full song structure using arrange(). Every pattern is inlined
// directly inside the template literal — no top-level let bindings.

export default `
  $: arrange(
    // 1) INTRO — kick and hi-hats only, no lead, no chord stab.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("hh*8").bank("RolandTR909").gain(0.3)
    )],

    // 2) VERSE — add the bassline, a soft piano pad, no lead yet.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
      sound("hh*8").bank("RolandTR909").gain(0.3),
      note("<c2 c2 g1 f2>").sound("sawtooth").lpf(800).gain(0.55),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4).gain(0.35)
    )],

    // 3) VERSE — same as above, but the lead synth enters with a
    //    simple C-E-G motif.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
      sound("hh*8").bank("RolandTR909").gain(0.3),
      note("<c2 c2 g1 f2>").sound("sawtooth").lpf(800).gain(0.55),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4).gain(0.35),
      note("c4 e4 g4 e4").sound("sawtooth").lpf(2500).room(0.3).gain(0.5)
    )],

    // 4) VERSE — the same verse, to extend the section.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
      sound("hh*8").bank("RolandTR909").gain(0.3),
      note("<c2 c2 g1 f2>").sound("sawtooth").lpf(800).gain(0.55),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4).gain(0.35),
      note("c4 e4 g4 e4").sound("sawtooth").lpf(2500).room(0.3).gain(0.5)
    )],

    // 5) VERSE — final bar of the verse. Same content as the others.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
      sound("hh*8").bank("RolandTR909").gain(0.3),
      note("<c2 c2 g1 f2>").sound("sawtooth").lpf(800).gain(0.55),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4).gain(0.35),
      note("c4 e4 g4 e4").sound("sawtooth").lpf(2500).room(0.3).gain(0.5)
    )],

    // 6) CHORUS — kick + clap + open hi-hat, fuller bass, lead up
    //    an octave, and a chord stab on top.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.8),
      sound("hh*8").bank("RolandTR909").gain(0.4).every(2, x => x.fast(2)),
      note("<c2 c2 g1 c2>").sound("sawtooth").lpf(1000).gain(0.7),
      chord("<Fmaj7 G7>").voicings("lefthand").sound("piano").room(0.4).gain(0.5),
      note("<c5 e5 g5 c5>").sound("sawtooth").lpf(3000).room(0.4).gain(0.55)
    )],

    // 7) CHORUS — second bar of the chorus, same as above.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(1.0),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.8),
      sound("hh*8").bank("RolandTR909").gain(0.4).every(2, x => x.fast(2)),
      note("<c2 c2 g1 c2>").sound("sawtooth").lpf(1000).gain(0.7),
      chord("<Fmaj7 G7>").voicings("lefthand").sound("piano").room(0.4).gain(0.5),
      note("<c5 e5 g5 c5>").sound("sawtooth").lpf(3000).room(0.4).gain(0.55)
    )],

    // 8) BRIDGE — strip back to piano + bass, change chord quality.
    [4, stack(
      sound("bd*2").bank("RolandTR909").gain(0.7),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.5),
      note("<a1 a1 f1 g1>").sound("sawtooth").lpf(700).gain(0.55),
      chord("<Dm7 G7>").voicings("lefthand").sound("piano").room(0.5).gain(0.5)
    )],

    // 9) BRIDGE — second bar of the bridge, with a sustained lead.
    [4, stack(
      sound("bd*2").bank("RolandTR909").gain(0.7),
      sound("~ cp ~ cp").bank("RolandTR909").gain(0.5),
      note("<a1 a1 f1 g1>").sound("sawtooth").lpf(700).gain(0.55),
      chord("<Dm7 G7>").voicings("lefthand").sound("piano").room(0.5).gain(0.5),
      note("<a4 c5 e5>").sound("sawtooth").lpf(2500).room(0.5).gain(0.5).slow(2)
    )],

    // 10) OUTRO — just the kick and the chord stab, fading out.
    [4, stack(
      sound("bd*4").bank("RolandTR909").gain(0.7),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.6).gain(0.3)
    )]
  )
`;
```

**Why this works:**

- `arrange(...)` is a top-level pattern combinator that plays each
  `[N, pattern]` slot for `N` cycles before moving to the next.
- The first number in each pair is the **length in cycles**, not
  beats or bars. With `setcpm(124/4)` (implicit here — the host
  pattern in `templates/src/pattern.js` is the default), one cycle
  is one bar at 124 BPM. So `[4, ...]` is 4 bars.
- **Every pattern is inlined inside the template literal.** There
  are zero `let verse = ...` or `const chorus = ...` declarations
  outside the template literal. The strudel.cc REPL evaluates the
  entire template literal in a single fresh scope, so inlined
  patterns are guaranteed to be in scope inside `arrange()`.
- The full structure here is: 4-bar intro + 4x4-bar verse + 2x4-bar
  chorus + 2x4-bar bridge + 4-bar outro = 16 + 8 + 8 + 4 = 36 bars.
- The lead and chord progression change in each section (verse
  uses I-vi in C, chorus uses IV-V, bridge uses ii-V), but every
  change happens by **duplicating the pattern with the new content
  inline** — not by referencing a top-level variable.

> **Mental model:** treat `arrange(...)` as a giant copy-paste list.
> Each section is a self-contained `stack(...)` with everything it
> needs. Do not factor common pieces into variables above the
> template literal; the REPL will not see them.

---

## When you are done

After writing any of these examples to `templates/src/pattern.js`:

1. Save the file.
2. Vite HMR fires `import.meta.hot.accept('./pattern.js', ...)` in
   `templates/src/main.js`.
3. The HMR handler calls `loadPattern(newModule.default)`, which
   base64-encodes the template literal and sets
   `iframe.src = "https://strudel.cc/?autoplay=1#<base64>"`.
4. The strudel.cc iframe reloads, the new pattern plays, and
   the audio resumes in under a second.

If you see `ReferenceError: <name> is not defined` inside the
iframe, a previous attempt has left a top-level `let` or `const`
binding that the strudel.cc scope cannot see. Inline the pattern
fragment directly inside the template literal and try again.
