# Art & Audio Reference

## 1. Procedural Vector Graphics & Visual Pipeline

All visuals in **BONK THE RAT!** are 100% procedurally rendered via Godot CanvasItem 2D vector primitives (`_draw()`), adhering to a strict zero-external-asset architecture (no external PNG, JPG, or SVG dependencies).

### Procedural Mallet Design (`src/art/mallet_painter.gd` & `src/game/mallet.gd`)
- **Mahogany Mallet Head:** Solid hardwood grain block with beveled lighting highlight, rounded edges, and dark wood shadows.
- **Dual Brass Retention Bands:** Polished golden-yellow metallic rings with specular highlight bands.
- **Cross-Wrapped Leather Grip:** Ash-wood handle wrapped with criss-cross dark leather strapping.
- **Arc Motion Swoosh:** Dynamic curved motion trail rendered during active down-swings.
- **Kinematics & Squash/Stretch:**
  - Anticipation tilt ($-65^\circ$) $\rightarrow$ snap impact ($+15^\circ$) with squash deformation (`Vector2(1.25, 0.75)`).
  - Spring-back recoil bounce restoring to resting state (`0^\circ`, `Vector2.ONE`).

### Expressive Rat Facial Expressions & Species Polish (`src/art/rat_painter.gd`)
- **Facial Animation States:**
  - **Normal:** Bright, alert eyes with reflective specular dots and twitching whiskers.
  - **Blinking:** Periodic autonomous eyelid blinks driven by sinusoidal timers.
  - **Dazed:** Triggered upon strike/stagger; renders dizzy spiral eyes (`@_@`) and orbiting comic stars above the head.
  - **Fleeing:** Squinted panic expression when retreating into the hole.
- **Species Accessories:**
  - **Normal Rat:** Classic pink ears, snout, and dark whiskers.
  - **Zoomer Rat:** Aerodynamic racing cap with reflective aviator goggles.
  - **Tank Rat:** Heavy riveted iron kettle helmet with beveled metallic gradient (2 HP).
  - **Golden Rat:** Gleaming royal crown studded with ruby and emerald gems.
  - **Clock Rat:** Antique brass pocketwatch dial with miniature clock hands.
  - **Star Rat:** Celestial golden star insignia with shimmering pulse glow.
  - **Boom Rat:** Black powder fuse bomb with glowing orange ember sparks (Hazard!).
  - **Whiskers the Cat:** Detailed tuxedo feline markings and forbidden warning border.

### Flying Rat Glider Actor (`src/game/flying_rat.gd` & `src/game/flying_rat_visual.gd`)
- **Visuals:** Leather aviator helmet, round pilot goggles, flapping bat/glider wings (dynamic sinusoidal flapping), and dangling golden bonus pouch.
- **Motion:** Continuous sinusoidal cruising wave across the top third of the board ($Y(t) = Y_0 + \sin(t \times 4.0) \times 28.0$).
- **Defeat Animation:** Mid-air strike initiates spinning tumble descent with burst particles.

### Particle & Screen Juice Effects (`src/game/fx_layer.gd`)
- **Expanding Shockwave Rings:** Radial stroke rings that expand outward ($8\text{px} \rightarrow 50\text{px}$) with rapid alpha decay upon impact.
- **Directional Bonk Sparks:** High-velocity spark burst particles radiating from the point of impact.
- **Pop Dirt Clouds:** Brown procedural smoke puffs whenever rats surface or submerge.
- **Confetti Cannons:** Multi-color celebratory confetti bursts upon 3-star level completion and bonus events.
- **Screen Shake & Hit-Stop:** Impact micro-freezes (12–40ms) and camera shake based on strike severity.

---

## 2. Audio Pipeline

All sound effects and music tracks in **BONK THE RAT!** are synthesized procedurally via GDScript tool scripts without external sample dependencies.

### Regeneration

To regenerate all audio assets (`res://assets/audio/*.wav`), run:

```bash
make audio
```

This runs `godot --headless --path . --script tools/generate_audio.gd`.

### Synthesis Toolkit (`tools/synth.gd`)

The `Synth` class provides pure mathematical DSP building blocks:
- **`buffer(seconds)`**: Allocates a zeroed 44.1 kHz float buffer.
- **`osc(...)` / `mix_osc(...)`**: Phase-accumulating multi-wave oscillator (`sine`, `square`, `saw`, `tri`, `noise`) with ADSR envelope modulation.
- **`tone(...)`**: Single-shot sliding tone generator.
- **`normalize(buf, peak)`**: Clamps dynamic range to prevent clipping.
- **`save_wav(buf, path)`**: Encodes 16-bit mono PCM into standard `.wav` files.

### Sound Effects Library

| SFX Name | Waveform / Timbre | Usage |
|---|---|---|
| `bonk` | Sliding sine thump + transient noise | Regular rat hit |
| `bonk_heavy` | Low-frequency thump + heavy transient | Tank rat hit |
| `squeak` | High square chirp | Whiskers rat / small rat cue |
| `whiff` | Swept noise gust | Mallet swing miss |
| `yowl` | Detuned falling saw pair | Whiskers hit penalty |
| `boom` | Low sub-bass drop + decaying noise | Bomb rat explosion |
| `freeze_chime` | Ascending triangle triad | Clock power-up start |
| `star_pickup` | Bright rising triangle arpeggio | Double points power-up start |
| `combo_1..5` | Progressively higher triangle intervals | Consecutive combo milestones |
| `star_fanfare` | Octave-stacked triangle chords | Star awarded at level end |
| `ui_click` | Crisp 1.2 kHz square blip | Menu button press |
| `ui_back` | Lower 600 Hz square blip | Menu back / cancel |
| `level_win` | 5-note rising C-major square melody | Level victory |
| `level_fail` | 3-note descending minor saw tones | Level defeat |

### Music Library

All music tracks are seamless 4-bar loops synthesized with distinct instrumental voicings per zone mood:

| Track Name | Tempo & Mood | Instrumentation |
|---|---|---|
| `music_menu` | 96 BPM gentle / cheerful | Triangle bass + soft triangle lead |
| `music_zone1` | 112 BPM bouncy pantry theme | Walking triangle bass + bouncy square lead + hi-hats |
| `music_zone2` | 88 BPM moody basement pad | Deep saw bass pad + melodic saw lead |
| `music_zone3` | 126 BPM driving kitchen frenzy | Fast alternating saw bass 8ths + square arpeggios + hi-hats |
| `music_endless` | 140 BPM hyper-speed arcade | Driving bass + dense 16th-note square leads + hi-hats |
