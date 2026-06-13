# Strudel Reference

This is the technical reference for the `strudel-music` skill. Read it when the
mini-notation, `setcpm`, `arrange()`, the natural-language mapping, or any
sample-bank question is not already covered by `SKILL.md` or `genres.md`.

> **Reminder:** every code snippet below is meant to live **inside the single
> backtick template literal** of `templates/src/pattern.js`. Do not bind any
> snippet to a top-level `let` or `const` (see `arrange()` below).

---

## Table of contents

- [Mini-notation syntax](#mini-notation-syntax)
- [setcpm and tempo control](#setcpm-and-tempo-control)
- [arrange() and the top-level let trap](#arrange-and-the-top-level-let-trap)
- [Variation and pattern combinators](#variation-and-pattern-combinators)
- [Notes, scales, and chords](#notes-scales-and-chords)
- [Sound banks and built-in synths](#sound-banks-and-built-in-synths)
- [Natural-language -> Strudel mapping table](#natural-language---strudel-mapping-table)
- [Common idioms](#common-idioms)
- [Troubleshooting quick reference](#troubleshooting-quick-reference)

---

## Mini-notation syntax

A "mini-notation" string is the argument to `sound(...)`, `note(...)`, `n(...)`,
`seq(...)`, or any pattern source. Whitespace separates events inside one
cycle, and the comma (`,`) runs them in parallel. The table below summarizes
the operators. Examples assume `sound("...")` for clarity.

| Syntax            | Name                  | Meaning                                                                                       |
| ----------------- | --------------------- | --------------------------------------------------------------------------------------------- |
| `a b c`           | Sequence (space)      | Play `a`, then `b`, then `c` within one cycle. Each event gets an equal step.                 |
| `a, b, c`         | Parallel (comma)      | Play `a`, `b`, and `c` simultaneously (layered). Use this to combine drum and bass parts.    |
| `a*2`             | Multiply              | Repeat `a` twice as fast within the cycle (e.g. `bd*2` = two kicks per cycle).                |
| `a/2`             | Divide                | Play `a` once over two cycles (slows it down; events get longer durations).                   |
| `a!3`             | Replicate (deprecated alias) | Equivalent to `a*3`. Prefer `*N`.                                                     |
| `a(n)`            | Step weight           | Replicate `a` `n` times in a row (`bd(3)` = `bd bd bd`).                                      |
| `[a b c]`         | Sub-sequence / polymeter | Play `a b c` evenly across the cycle, regardless of how many steps the parent has.       |
| `<a b c>`         | Choose / alternate    | On each cycle, pick one of `a`, `b`, or `c` (equal probability).                              |
| `<a b c>!2`       | Slow-choose           | Same as above but switch only every other cycle.                                              |
| `{a b c}%4`       | Euclidean             | Distribute the events `a b c` as evenly as possible across 4 steps (e.g. `{bd hh}%8`).        |
| `~`               | Rest / silence        | A silent step. `bd ~ sd ~` is a four-on-the-floor.                                            |
| `.`               | Sample-bank separator | Inside one event, separate bank and name: `sd.r` or `sd:RolandTR808`.                         |
| `|`               | Elongate              | Lengthen the previous event by one step (`bd|` holds the kick for two steps).                 |
| `?`               | Random gate           | 50% chance to play the event. `bd?` plays a kick half the time.                               |
| `@`               | Sustain               | Hold the sample to fill the rest of its step (good for short percussion loops).              |

### Notes and pitch

The same operators apply to `note("...")`. Notes use lower-case letters and
sharps:

| Syntax         | Meaning                                                  |
| -------------- | -------------------------------------------------------- |
| `c d e f g`    | C, D, E, F, G (white keys).                              |
| `c# d# f# g# a#` | Sharps. Use `s` for the German sharp form on some inputs. |
| `cb bb` etc.   | Flats are usually entered as `db eb gb ab bb` (the flat letter names). |
| `c4`           | Middle C (MIDI 60). Default octave is 4.                 |
| `c5`           | One octave up.                                           |
| `[c3, c4]`     | A chord; commas inside a sub-sequence are stacked.       |

### Numbers and parameters inside events

`n("0 2 4 7")` plays MIDI note numbers 0, 2, 4, 7. `n("0*4")` plays 0 four
times per cycle. Combining `note` and `n` is uncommon; pick one per pattern.

---

## setcpm and tempo control

`setcpm(cyclesPerMinute)` sets the global cycle length. Strudel plays
**one cycle per `1/cpm` minutes**, so a higher number is faster.

| NL intent             | setcpm value         | Approx. BPM if 4 steps/cycle |
| --------------------- | -------------------- | ---------------------------- |
| Very slow drone       | `setcpm(30/4)`       | ~30 BPM                      |
| Ambient / downtempo   | `setcpm(45/4)`       | ~45 BPM                      |
| Lo-fi / hip-hop       | `setcpm(60/4)`       | ~60 BPM                      |
| House / pop           | `setcpm(90/4)`       | ~90 BPM                      |
| Disco / techno        | `setcpm(120/4)`      | ~120 BPM                     |
| Drum and bass         | `setcpm(174/4)`      | ~174 BPM                     |
| Hardcore              | `setcpm(200/4)`      | ~200 BPM                     |

`setcpm` is **not** BPM. The relationship is
`bpm = cpm * stepsPerCycle`. For the common 4-step grid, divide by 4.
If the user specifies an exact BPM (e.g. "128 BPM house"), use
`setcpm(128/4)`.

You can also slow or speed up a single pattern with `.slow(N)` or `.fast(N)`
without changing the global tempo. `setcpm` is the right tool when the
**whole song** needs a different pulse.

`setcpm` may appear at most once per pattern, and should be the first line:

```
setcpm(90/4)
$: sound("bd sd").bank("RolandTR808")
```

If you need to vary tempo across sections, use `arrange()` with several
patterns, each starting with its own `setcpm`:

```
arrange(
  [4, (setcpm(90/4); sound("bd sd"))],
  [4, (setcpm(120/4); sound("bd sd").fast(2))]
)
```

---

## arrange() and the top-level let trap

`arrange(... [steps, pattern])` plays each `pattern` for `steps` cycles
before moving to the next. It is the standard way to write a verse / chorus /
bridge structure inside a single `pattern.js` template literal.

### The trap

The strudel.cc REPL evaluates the **entire template literal in a fresh
scope on every reload**. Top-level `let` or `const` bindings declared in
`pattern.js` (outside the template literal) are **not** in that scope.
Referencing them inside `arrange()` raises `ReferenceError`.

### WRONG

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

The error you will see inside the iframe is
`ReferenceError: verse is not defined`.

### CORRECT

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

The rule is the same as the SKILL hard rules: **inline everything inside
the template literal**. The example file `examples.md` demonstrates a
full song in this style.

---

## Variation and pattern combinators

These are the safe-to-use-anywhere primitives. None of them require a
top-level binding.

| Function / method            | Effect                                                          |
| ---------------------------- | --------------------------------------------------------------- |
| `stack(a, b, c)`             | Play patterns in parallel (same as `a, b, c` inside one source).|
| `cat(a, b, c)`               | Concatenate: play `a`, then `b`, then `c`, cycling through.     |
| `seq(... )`                  | Like `cat` but the cycle length follows the list length.        |
| `.slow(N)`                   | Halve speed N times (N=2 is half-time).                         |
| `.fast(N)`                   | Double speed N times (N=2 is double-time).                      |
| `.every(N, fn)`              | Apply `fn` only every N cycles. `every(4, x => x.fast(2))`.     |
| `.add(n)`                    | Transpose up `n` semitones.                                     |
| `.sub(n)`                    | Transpose down `n` semitones.                                   |
| `.gain(0.6)`                 | Volume multiplier (0..1, default 1).                            |
| `.lpf(2000)`                 | Low-pass filter cutoff in Hz.                                   |
| `.hpf(200)`                  | High-pass filter cutoff in Hz.                                  |
| `.room(0.5)`                 | Reverb send (0..1).                                             |
| `.delay(0.25)`               | Delay send (0..1).                                              |
| `.delaytime(0.375)`          | Delay time in seconds.                                          |
| `.delayfeedback(0.4)`        | Delay feedback amount.                                          |
| `.rev()`                     | Reverse the pattern within a cycle.                             |
| `.chunk(N, fn)`              | Apply `fn` only to the Nth part of the pattern.                 |
| `.struct("t f t f")`         | Mask with a Boolean rhythm. `t` plays, `f` silences.            |
| `.mask("t f t f")`           | Alias for `.struct` with the same syntax.                       |
| `s("...")`                   | Shorthand for `sound("...")`.                                   |
| `n("0 2 4 7")`               | MIDI note numbers (0..127).                                     |

---

## Notes, scales, and chords

| Function / syntax     | Meaning                                                                 |
| --------------------- | ----------------------------------------------------------------------- |
| `note("c e g")`       | Explicit pitches.                                                       |
| `n("0 2 4 7")`        | MIDI numbers (0 = C-1, 60 = middle C, 127 = G9).                        |
| `.scale("C:minor")`   | Constrain `n(...)` to a scale. Built-ins include major, minor, dorian, mixolydian, blues, pentatonic, and the harmonic variants. |
| `.scaleTranspose(2)`  | Shift the scale by N scale degrees.                                     |
| `chord("<Cm Fm G7>")` | Cycle through chord names; pair with `.arp("up")` or `.arp("updown")`.  |
| `.voicings("lefthand")` | Restrict a chord pattern to a piano-friendly voicing.                  |
| `.rootNote(60)`       | Set the root MIDI note for `chord(...)`.                                |

A typical chord progression:

```
chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand")
  .sound("piano")
  .room(0.3)
```

---

## Sound banks and built-in synths

### Sample banks (drum-machine style)

`scripts/download-samples.sh` mirrors the upstream
`tidal-drum-machines` repo into `${HOME}/strudel-music/public/samples/`.
The names below are the bank names you pass to `.bank("...")`:

- `RolandTR808` — classic 808 hip-hop / trap kit.
- `RolandTR909` — 909 house / techno kit.
- `RolandTR707` — 707 kit (snappy).
- `LinnLM1`, `LinnLM2` — Linn drum sounds.
- `AkaiLinn`, `AkaiMPC60`, `AkaiS900`, `AkaiS1000`.
- `BOSS_DR110`, `BOSS_DR220`, `BOSS_DR55`.
- `CasioRZ1`, `CasioSK1`, `CasioSA10`.
- `OberheimDMX`, `E-muSP12`, `KorgKR55`, `KorgM1`, `KorgMinipops`.
- `YamahaRM50`, `YamahaRX5`, `YamahaRX21`, `YamahaTCS10`.

If the bank is not in the list above, the strudel.cc REPL will fail with
`Could not load bank '<name>'`. Fall back to a built-in synth.

### Built-in synths (no samples required)

`sound("...")` accepts the synth names below, which work even before
`scripts/download-samples.sh` has been run:

- `square` — chiptune square wave.
- `sawtooth` — bright saw wave (good for bass and lead).
- `triangle` / `sine` — soft tones (good for pads and sub-bass).
- `piano`, `gm_piano`, `gm_epiano1`, `gm_epiano2` — General MIDI patches.
- `bass` — a basic bass patch.
- `saw` — alias for `sawtooth`.
- `sine` — alias for sine.

For a quick "does it play?" sanity check, use
`note("c e g").sound("square")` — that is also the default starter pattern
in `templates/src/pattern.js`.

---

## Natural-language -> Strudel mapping table

When the user's request is ambiguous, use this table to pick a default
before asking. If the user is precise, follow their wording exactly.

### Tempo

| User says                          | Default                       | Notes                                   |
| ---------------------------------- | ----------------------------- | --------------------------------------- |
| "slow" / "downtempo"               | `setcpm(45/4)`                | ~45 BPM.                                |
| "medium tempo" / "walking pace"    | `setcpm(75/4)`                | ~75 BPM.                                |
| "house" / "pop"                    | `setcpm(90/4)`                | 90 BPM, the standard grid.              |
| "disco" / "techno"                 | `setcpm(120/4)`               | 120 BPM.                                |
| "drum and bass" / "DnB"            | `setcpm(87/2)` (174 cpm)      | Two steps per cycle is the DnB norm.   |
| "BPM <N>"                          | `setcpm(<N>/4)`               | Use the user's number verbatim.         |
| "half time"                        | take the chosen `setcpm` and `.slow(2)` on the drum part | Halve the drum speed only. |
| "double time"                      | `.fast(2)` on the drum part   | Doubles the drum speed only.            |

### Rhythm

| User says                          | Default mini-notation                  | Notes                          |
| ---------------------------------- | -------------------------------------- | ------------------------------ |
| "four on the floor"                | `bd*4` (or `bd ~ bd ~`)                | One kick per step.             |
| "backbeat"                         | `~ sd ~ sd`                            | Snare on 2 and 4.              |
| "breakbeat"                        | `bd sd bd [~ sd]`                      | Irregular, syncopated.         |
| "trap hi-hats"                     | `hh*8` with `.every(2, x => x.fast(2))`| Triplet rolls on the off-beat. |
| "boom-bap"                         | `bd ~ sd ~` with `hh*4`                | Classic 90s hip-hop.           |
| "swing" / "shuffle"                | `note("c3(3,8)")` or `.swing(0.3)`      | Off-beat pushes back ~33%.     |
| "polyrhythm" / "3 against 2"       | stack(`a*3`, `b*2`)                    | Two patterns, different rates. |
| "rest" / "silence for a bar"       | `~ ~ ~ ~`                              | A silent step.                 |
| "fill at the end"                  | `.every(8, x => x.fast(2))`            | Brief speedup on cycle 8.      |

### Melody and harmony

| User says                          | Default pattern                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------- |
| "in C minor"                       | `n("0 2 3 5 7").scale("C:minor")`                                            |
| "in E pentatonic"                  | `n("0 2 4 7 9").scale("E:minor:pentatonic")`                                 |
| "bluesy"                           | `n("0 3 5 6 7 10").scale("C:minor:blues")`                                   |
| "major key"                        | `n("0 2 4 5 7 9 11").scale("C:major")`                                       |
| "jazz chord progression"           | `chord("<Dm7 G7 Cmaj7 Am7>")`                                                |
| "arpeggio"                         | `chord("Cmaj7").arp("up")` or `chord("Cmaj7").arp("updown")`                |
| "low / bassy"                      | `.sub(12)` or `note("c2 e2 g2")`                                             |
| "high / bright"                    | `.add(12)` or `note("c5 e5 g5")`                                             |
| "dissonant" / "atonal"              | `n("<0 1 3 6 8 11>")` (no scale constraint)                                  |
| "modal" / "no clear key"           | `n("0 2 4 5 7").scale("D:dorian")`                                           |

### Texture

| User says                          | Default modifier chain                                                  |
| ---------------------------------- | ----------------------------------------------------------------------- |
| "ambient" / "pads"                 | `.slow(4)`, `.room(0.7)`, `.lpf(1500)`, `.gain(0.5)`                    |
| "bright" / "airy"                  | `.hpf(400)`, `.gain(0.6)`                                               |
| "muffled" / "lo-fi"                | `.lpf(800)`, `.room(0.2)`, plus sample-rate reduction via `.crush(8)`   |
| "staccato" / "tight"               | `.legato(0.3)` (low value)                                              |
| "legato" / "smooth"                | `.legato(0.8)` (high value)                                             |
| "reverb-heavy"                     | `.room(0.8)` and `.size(0.9)`                                            |
| "delay" / "echo"                   | `.delay(0.4)`, `.delaytime(0.375)`, `.delayfeedback(0.45)`               |
| "filtered" / "low-pass"            | `.lpf(<Hz>)` where `<Hz>` is the cutoff                                  |
| "distorted" / "gritty"             | `.shape(0.6)` (waveshaping) or `.distort(0.4)`                           |
| "punchy" / "loud"                  | `.gain(0.9)`, `.lpf(8000)`                                              |

### Instruments

| User says                          | Default sound / bank                                                     |
| ---------------------------------- | ------------------------------------------------------------------------ |
| "kick" / "bass drum"               | `sound("bd")` with `.bank("RolandTR808")` (or `"RolandTR909"`)           |
| "snare"                            | `sound("sd")` with `.bank("RolandTR808")`                                |
| "hi-hat" / "hats"                  | `sound("hh")` with `.bank("RolandTR808")`                                |
| "open hi-hat"                      | `sound("oh")` with `.bank("RolandTR808")`                                |
| "clap"                             | `sound("cp")` with `.bank("RolandTR808")`                                |
| "rim"                              | `sound("rim")` with `.bank("RolandTR808")`                               |
| "cowbell"                          | `sound("cb")` with `.bank("RolandTR808")`                                |
| "piano"                            | `note("...").sound("piano")`                                             |
| "electric piano" / "rhodes"        | `note("...").sound("gm_epiano1")`                                       |
| "bass synth"                       | `note("c2 c2 g1").sound("sawtooth")`                                     |
| "sub-bass"                         | `note("c2").sound("sine").lpf(150)`                                     |
| "lead synth"                       | `note("...").sound("sawtooth").lpf(4000)`                                |
| "pad"                              | `note("...").sound("sawtooth").slow(4).room(0.7)`                        |
| "organ"                            | `note("...").sound("gm_organ")`                                          |
| "guitar"                           | `note("...").sound("gm_nylon_guitar")`                                   |
| "strings"                          | `note("...").sound("gm_strings")`                                        |
| "brass"                            | `note("...").sound("gm_brass")`                                          |
| "808 sub" / "trap 808"             | `note("c1").sound("sine").lpf(80).gain(0.9)`                             |

If the user names a sound you do not recognize (e.g. "909 clap", "cowbell",
"marimba"), search `genres.md` first. If it is not there, prefer the
closest built-in synth.

---

## Common idioms

### Layered drum kit

```
$: stack(
  sound("bd*4").bank("RolandTR808"),
  sound("~ sd ~ sd").bank("RolandTR808").gain(0.9),
  sound("hh*8").bank("RolandTR808").gain(0.4)
)
```

### Bass + chord

```
$: stack(
  note("<c2 c2 g1 f2>").sound("sawtooth").lpf(800).gain(0.8),
  chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").room(0.3)
)
```

### Euclidean hi-hats

```
$: sound("hh*16").bank("RolandTR808").gain(0.3).every(2, x => x.fast(2))
```

### Four-bar song with arrange()

```
$: arrange(
  [4, stack(sound("bd*4").bank("RolandTR808"), sound("~ sd ~ sd").bank("RolandTR808"))],
  [4, stack(sound("bd*4").bank("RolandTR808"), sound("~ sd ~ sd").bank("RolandTR808"), sound("hh*8").bank("RolandTR808").gain(0.3))],
  [4, stack(sound("bd*4").bank("RolandTR808"), sound("~ sd ~ sd").bank("RolandTR808"), sound("hh*8").bank("RolandTR808").gain(0.3), note("c e g").sound("square"))],
  [2, sound("~ clap:2 ~ clap:2").bank("RolandTR808")]
)
```

### Slow ambient drone

```
setcpm(45/4)
$: note("c2 g2").sound("sawtooth").slow(8).lpf(800).room(0.8).gain(0.4)
```

### Polyrhythm

```
$: stack(
  sound("bd*3").bank("RolandTR808"),
  sound("sd*2").bank("RolandTR808")
)
```

---

## Troubleshooting quick reference

| Symptom                                          | Cause                                            | Fix                                                                                              |
| ------------------------------------------------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `ReferenceError: <name> is not defined` in REPL  | Top-level `let` referenced inside `arrange()`.   | Inline every pattern fragment inside the template literal (see `arrange()` above).               |
| `Could not load bank '<name>'`                   | Bank name not in `tidal-drum-machines` manifest. | Replace with `note("...").sound("square" / "sawtooth" / "sine" / "piano")`.                      |
| `sound is not a function` / `s is not a function` | The agent imported a `@strudel/*` package.     | Remove all `import` lines. `pattern.js` has exactly one `export default` statement.              |
| Pattern plays but tempo is wrong                 | `setcpm` is in cycles per minute, not BPM.     | Use `setcpm(bpm / 4)` for the 4-step grid.                                                       |
| HMR fires but the iframe flashes white           | The cross-origin iframe is rebuilding on hash change. | Cosmetic only; audio resumes in <1 s.                                                       |
| Nothing plays at all on first load               | Browser autoplay policy.                         | The user must click the play button inside the iframe once.                                      |

For the full troubleshooting table, see `SKILL.md`.
