# Art & Audio Reference

## Audio Pipeline

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
