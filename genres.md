# Genre Templates

This file is a catalogue of working Strudel patterns, one per major genre.
Each pattern below is **runnable as-is in the strudel.cc REPL** and uses
**only Strudel primitives documented in `reference.md`** (no invented
functions, no `import`s, no top-level `let` bindings).

When the user asks for a genre you do not have a strong default for, copy
the closest pattern from this file into `templates/src/pattern.js` and
iterate from there. See `examples.md` for paired natural-language prompts
that show how these templates combine with `arrange()`.

---

## Table of contents

- [House](#house)
- [Techno](#techno)
- [Hip-Hop](#hip-hop)
- [Jazz](#jazz)
- [Ambient](#ambient)
- [Drum and Bass](#drum-and-bass)
- [Reggae](#reggae)
- [Bossa Nova](#bossa-nova)
- [Classical](#classical)
- [Lo-Fi](#lo-fi)
- [Pop / EDM (pop-edm)](#pop-edm)
- [How to combine genres](#how-to-combine-genres)

---

## House

**Tempo:** 120-128 BPM (`setcpm(120/4)` to `setcpm(128/4)`)
**Bank:** `RolandTR909` (the standard house kit)
**Feel:** four-on-the-floor kick, off-beat clap, shuffled hi-hats, simple
sub-driven bass.

```js
export default `
  setcpm(124/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.8),
    sound("hh*8").bank("RolandTR909").gain(0.35).every(2, x => x.fast(2)),
    note("<c2 c2 f1 g1>").sound("sawtooth").lpf(800).gain(0.65)
  )
`;
```

What makes it House: the kick hits every quarter note, the clap fills the
backbeat, the bass is a one-note pulse, and the hi-hats open on the off-beat
via `every(2, x => x.fast(2))`.

---

## Techno

**Tempo:** 128-140 BPM (`setcpm(128/4)` to `setcpm(140/4)`)
**Bank:** `RolandTR909`
**Feel:** harder kick, longer clap, driving hi-hats, acid-style bass.

```js
export default `
  setcpm(132/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0).lpf(200),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
    sound("hh*8").bank("RolandTR909").gain(0.4).every(2, x => x.fast(2)),
    note("<c1 c1 eb1 g1>").sound("sawtooth").lpf(600).gain(0.6).room(0.2)
  )
`;
```

What makes it Techno: a more aggressively filtered kick, a more insistent
bass riff, and the same TR-909 backbone as house but pushed harder.

---

## Hip-Hop

**Tempo:** 85-95 BPM (`setcpm(85/4)` to `setcpm(95/4)`)
**Bank:** `RolandTR808`
**Feel:** boom-bap kick + snare pattern, swung hi-hats, simple sub bass.

```js
export default `
  setcpm(90/4)
  $: stack(
    sound("bd ~ sd ~").bank("RolandTR808").gain(0.95),
    sound("hh*4").bank("RolandTR808").gain(0.35).room(0.4),
    sound("~ ~ sd ~").bank("RolandTR808").gain(0.7),
    note("<c1 g1 c1 f1>").sound("sawtooth").lpf(400).gain(0.55)
  )
`;
```

What makes it Hip-Hop: the kick-snare back-and-forth, the swung 16th-note
hi-hats (`hh*4` with `room`), and the TR-808 bank (the canonical 808 kit).

---

## Jazz

**Tempo:** 100-180 BPM (`setcpm(120/4)` is a comfortable default)
**Banks:** piano, bass, ride-style hi-hats
**Feel:** 7th-chord voicings, walking bass, brushed hi-hats.

```js
export default `
  setcpm(120/4)
  $: stack(
    chord("<Dm7 G7 Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4),
    note("<d2 c2 b1 a1>").sound("bass").gain(0.7),
    sound("~ hh ~ hh ~ hh ~ hh").bank("RolandTR909").gain(0.2).room(0.3)
  )
`;
```

What makes it Jazz: the `Dm7 G7 Cmaj7 Am7` ii-V-I-vi cycle, the
`voicings("lefthand")` for piano-friendly chord shapes, and the walked
bass line descending `d c b a`.

---

## Ambient

**Tempo:** 30-50 BPM (`setcpm(30/4)` to `setcpm(50/4)`)
**Synths:** `sawtooth`, `sine`
**Feel:** slow, evolving, no drum rhythm, lots of reverb.

```js
export default `
  setcpm(45/4)
  $: stack(
    note("c3 g3 e4").sound("sawtooth").slow(8).lpf(800).room(0.8).gain(0.3),
    note("c2 g2").sound("sine").slow(8).gain(0.3)
  )
`;
```

What makes it Ambient: the `.slow(8)` stretches the chord to evolve over
many seconds, `.room(0.8)` puts the texture in a huge space, and `.lpf(800)`
keeps the high end muted. No drums.

---

## Drum and Bass

**Tempo:** 170-180 BPM (`setcpm(87/2)` to `setcpm(90/2)` — two steps per
cycle is the DnB convention)
**Bank:** `RolandTR808`
**Feel:** fast break, rolling bassline, syncopated snare.

```js
export default `
  setcpm(87/2)
  $: stack(
    sound("[bd sd] [sd bd] [bd sd] [~ sd]").bank("RolandTR808").gain(0.95),
    sound("hh*16").bank("RolandTR808").gain(0.3).every(2, x => x.fast(2)),
    note("<c1 c1 eb1 g1 c2>").sound("sawtooth").lpf(1200).gain(0.6)
  )
`;
```

What makes it DnB: the drum break uses an irregular pattern
`[bd sd] [sd bd] [bd sd] [~ sd]`, the hi-hats roll at 16 steps per cycle
with a `.fast(2)` accent every other cycle, and `setcpm(87/2)` gives the
classic 174-BPM break tempo.

---

## Reggae

**Tempo:** 70-90 BPM (`setcpm(70/4)` to `setcpm(90/4)`)
**Bank:** `RolandTR808`
**Feel:** one-drop (kick + snare both on beat 3), guitar on the off-beat.

```js
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

What makes it Reggae: the **one-drop** — both kick and snare hit on beat 3
(positions 3 in a 4-step cycle), and the guitar plays on the off-beats
between the bass notes. `gm_nylon_guitar` is the closest built-in to a
reggae "skank" guitar.

---

## Bossa Nova

**Tempo:** 95-110 BPM (`setcpm(100/4)`)
**Bank:** `RolandTR808` (or piano only)
**Feel:** syncopated 16th-note clave, nylon guitar, soft piano.

```js
export default `
  setcpm(100/4)
  $: stack(
    sound("[~ cp] [hh ~] [~ ~ cp] [hh ~ cp]").bank("RolandTR808").gain(0.4),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("gm_nylon_guitar").gain(0.5).room(0.3),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").gain(0.3).delay(0.3)
  )
`;
```

What makes it Bossa Nova: the clave-style rhythm
`[~ cp] [hh ~] [~ ~ cp] [hh ~ cp]` and the nylon guitar voicing. The
soft piano lays down the same chords an octave up under a gentle delay.

---

## Classical

**Tempo:** 50-80 BPM (`setcpm(60/4)` for a slow movement)
**Synths:** `piano` (or `gm_strings` for orchestral feel)
**Feel:** no drums, slow chordal motion, melodic lead.

```js
export default `
  setcpm(60/4)
  $: stack(
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").room(0.5).gain(0.6),
    note("<c5 e5 g5 e5 f5 d5 c5>").sound("piano").room(0.5).gain(0.5).slow(2)
  )
`;
```

What makes it Classical: no drum programming at all, the `.slow(2)` on the
melody gives it a lyrical feel, and `.room(0.5)` puts the piano in a
recital-hall space. For an orchestral version, replace `sound("piano")`
with `sound("gm_strings")`.

---

## Lo-Fi

**Tempo:** 65-80 BPM (`setcpm(70/4)`)
**Bank:** `RolandTR808`
**Feel:** boom-bap drums filtered down, dusty piano, vinyl warmth.

```js
export default `
  setcpm(70/4)
  $: stack(
    sound("bd ~ sd ~").bank("RolandTR808").gain(0.7).lpf(300),
    sound("hh*4").bank("RolandTR808").gain(0.3).lpf(800),
    chord("<Cmaj7 Am7 Dm7 G7>").voicings("lefthand").sound("piano").room(0.5).gain(0.4)
  )
`;
```

What makes it Lo-Fi: the heavy `.lpf(300)` on the kick and `.lpf(800)` on
the hats strip the high end off the drums, and `.room(0.5)` on the piano
adds the "tape hiss" feel. The drum pattern is the same boom-bap as
Hip-Hop but slower and more filtered.

---

## Pop-EDM

Also spelled "pop-edm" or "Pop/EDM". This is the festival/dance-pop feel
that lives at 120-130 BPM with a four-on-the-floor kick and chord stabs.

**Tempo:** 120-130 BPM (`setcpm(128/4)` is the festival default)
**Bank:** `RolandTR909`
**Feel:** big four-on-the-floor, side-chained synth stabs, anthemic lead.

```js
export default `
  setcpm(128/4)
  $: stack(
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
    sound("hh*8").bank("RolandTR909").gain(0.3),
    note("<c4 e4 g4 c5>").sound("sawtooth").lpf(3000).room(0.4).gain(0.5)
  )
`;
```

What makes it Pop/EDM: 128 BPM, the four-on-the-floor, and the chord stab
on top (a major-triad arpeggio). Add `.every(4, x => x.rev())` to the lead
to get a pre-chorus lift.

---

## How to combine genres

Two ways to mix templates:

### Stack two genres in parallel

```js
export default `
  setcpm(120/4)
  $: stack(
    // House backbone
    sound("bd*4").bank("RolandTR909").gain(1.0),
    sound("~ cp ~ cp").bank("RolandTR909").gain(0.7),
    // Jazz harmony on top
    chord("<Dm7 G7 Cmaj7 Am7>").voicings("lefthand").sound("piano").room(0.4)
  )
`;
```

### Section a song with `arrange()`

```js
export default `
  $: arrange(
    [4, stack(
      sound("bd*4").bank("RolandTR808").gain(0.9),
      sound("~ ~ sd ~").bank("RolandTR808").gain(0.7),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").gain(0.4)
    )],
    [4, stack(
      sound("bd*4").bank("RolandTR808").gain(0.9),
      sound("hh*8").bank("RolandTR808").gain(0.3),
      chord("<Fmaj7 G7>").voicings("lefthand").sound("piano").gain(0.4),
      note("<c4 e4 g4>").sound("sawtooth").gain(0.5)
    )],
    [4, stack(
      sound("bd*4").bank("RolandTR808").gain(0.9),
      sound("~ ~ sd ~").bank("RolandTR808").gain(0.7),
      chord("<Cmaj7 Am7>").voicings("lefthand").sound("piano").gain(0.4)
    )]
  )
`;
```

Both forms use only documented primitives; both are safe to copy directly
into `templates/src/pattern.js`.
