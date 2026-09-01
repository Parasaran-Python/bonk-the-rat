# BONK THE RAT! — Gameplay & Graphics Overhaul Specification

**Date:** 2026-09-01  
**Status:** Approved for Implementation  
**Target:** Godot 4.6.1 stable (Headless verification compatible)

---

## 1. Executive Summary

This specification outlines the comprehensive overhaul of **BONK THE RAT!**, incorporating:
1. **Dynamic Grid & Speed Progression:** Campaign scaling across 15 levels spanning $3\times2$ (6 holes) $\rightarrow$ $3\times3$ (9 holes) $\rightarrow$ $4\times3$ (12 holes) $\rightarrow$ $5\times3$ (15 holes in grand finale levels 14–15 and Endless Mode), coupled with dynamic spawn acceleration down to $0.30\text{s}$ intervals and concurrency caps scaling up to 7 simultaneous rats.
2. **Graphics & Hammer Animation Polish:** Redesigned mallet with metallic brass banding, wood-grain handle, and leather wraps; dynamic arc swing animations with motion wind swooshes, impact head squash ($1.2\times0.7$), recoil bounce, directional spark bursts, and expanding impact shockwave rings; expressive rat facial animations with blinking eyes, dazed spiral eyes (`@_@`), and floating comic stars upon impact.
3. **Flying Rat Event Mechanic:** An autonomous high-altitude glider/bat rat actor swooping across the top screen in a smooth sine-wave trajectory; flapping procedural wings, pilot goggles, and carrying a golden prize. Mid-air bonk awards $+1,000$ points, confetti/star bursts, and an instant powerup buff (Freeze or 2x Double Points), while cleanly exiting off-screen with zero penalty if missed.

---

## 2. Subsystem Architecture & Changes

### 2.1 Level Progression & Grid Scaling

* **Level Table Tuning (`tools/generate_levels.gd`):**
  - **Zone 1: The Warm Pantry (Levels 1–5)**
    - Levels 1–3: $3\times2$ grid (6 holes), introducing Normal, Zoomer, and Clock (Freeze) rats. Max concurrent: 1–2. Spawn intervals: $1.40\text{s} \rightarrow 0.85\text{s}$.
    - Levels 4–5: $3\times3$ grid (9 holes), introducing Tank rats (2 HP) and Star powerup (2x). Max concurrent: 2–3. Spawn intervals: $1.15\text{s} \rightarrow 0.75\text{s}$.
  - **Zone 2: The Cold Basement (Levels 6–10)**
    - Levels 6–8: $3\times3$ grid (9 holes), introducing Golden rats (+500 pts) and Whiskers cat hazard. Max concurrent: 3–4. Spawn intervals: $1.05\text{s} \rightarrow 0.65\text{s}$.
    - Levels 9–10: $4\times3$ grid (12 holes), dense mixed waves. Max concurrent: 4–5. Spawn intervals: $0.94\text{s} \rightarrow 0.58\text{s}$.
  - **Zone 3: The Midnight Kitchen (Levels 11–15)**
    - Levels 11–13: $4\times3$ grid (12 holes), introducing Boom rat hazard. Max concurrent: 4–5. Spawn intervals: $0.85\text{s} \rightarrow 0.50\text{s}$.
    - Levels 14–15 (Grand Finale): $5\times3$ grid (15 holes!), ultra-fast frenzy waves. Max concurrent: 6–7. Spawn intervals: $0.65\text{s} \rightarrow 0.30\text{s}$.
  - **Endless Mode (`src/data/levels/endless.tres`):**
    - $5\times3$ grid (15 holes), starting concurrency 4, dynamic wave speed $1.0 + 0.15 \times (\text{wave}-1)$, concurrency cap increasing by $+1$ every 3 waves (up to 7).
* **Board Auto-Scaling (`src/game/board.gd`):**
  - `_reposition_holes()` computes `_board_scale` dynamically:
    $$\text{scale}_w = \frac{\text{viewport}_x \times 0.90}{\text{total}_w}, \quad \text{scale}_h = \frac{\text{viewport}_y \times 0.52}{\text{total}_h}$$
    $$\text{scale} = \min(1.0, \min(\text{scale}_w, \text{scale}_h))$$
  - Hit radius in `HitTest.pick()` automatically scales with `78.0 * _board_scale`.

---

### 2.2 Graphics, Sprites & Hammer Hit Animations

* **Mallet Painter & Actor (`src/art/mallet_painter.gd`, `src/game/mallet.gd`):**
  - **Procedural Visuals:** Metallic brass bands, beveled dark cherry wood head with top specular reflection lines, leather grip criss-cross wraps on the handle, and soft drop shadow.
  - **Swing Lifecycle:**
    1. *Anticipation:* Quick $-65^\circ$ cock-back tilt with subtle scale stretch.
    2. *Arc Stroke:* Fast down-swing to $+12^\circ$ with a vector wind swoosh arc drawn behind the head.
    3. *Impact Compression:* Head squash to Vector2(1.25, 0.75) for 0.04s on hit.
    4. *Recoil & Recovery:* Spring back to $0^\circ$ and Vector2.ONE over 0.06s.
* **Procedural Rat Sprites & Facial States (`src/art/rat_painter.gd`, `src/game/rat.gd`):**
  - **Expression States:**
    - *Normal / Idle:* Random blink animation timer triggering eyelids over eyes.
    - *Staggered / Hit:* Dizzy spiral eyes (`@_@`), comic stars orbiting head, mouth agape, and squash-and-stretch deformation.
  - **Enhanced Species Details:**
    - *Zoomer:* Goggle glass tint, lens flare glints, swept-back ear tips.
    - *Tank:* Riveted iron helmet plates, chin strap, steel shine highlights.
    - *Golden:* Shimmering 5-point crown with sparkling particle emission.
    - *Boom:* Sizzling yellow/orange fuse spark on the bomb.
    - *Star & Clock:* Radiant halo pulses and ticking clock hands.
* **Juice & FX Layer (`src/game/fx_layer.gd`):**
  - **Impact Shockwaves:** Expanding circular shockwave ring expanding from radius 10px to 55px and fading out over 0.25s on bonk.
  - **Directional Sparks:** 8–12 bright yellow/white spark streaks ejecting upwards from hit point.

---

### 2.3 Flying Rat Event Mechanic

* **Actor Lifecycle (`src/game/flying_rat.gd`, `src/game/flying_rat.tscn`):**
  - High-altitude airborne actor rendered at $z\text{-index} = 200$ (above holes, below HUD).
  - **Flight Math:**
    - Spawns at $X = -80$ (left-to-right) or $X = \text{viewport}_x + 80$ (right-to-left).
    - Flies horizontally across screen at $Y(t) = Y_0 + \sin(t \times 4.0) \times 28.0$.
    - Speed: $380\text{px/s}$, crossing screen in $\sim 3.5\text{s}$.
  - **Procedural Visuals (`RatPainter.draw_flying_rat`):**
    - Flapping bat/glider wings (sine-modulated wing angle).
    - Aviator leather flight cap and goggles.
    - Carrying a dangling glowing golden cheese / powerup pouch.
  - **Hit Detection:**
    - `Board.swing_at(pos)` checks active flying rat before or alongside ground holes.
    - Effective hit radius: $60\text{px}$.
  - **Bonk Outcome:**
    - Points: $+1,000$ points added directly to score.
    - Powerup: Triggers either Freeze or 2x Double Points buff.
    - FX: Confetti explosion, star burst, screen shake (4.0), and golden chime SFX.
    - Exit: Spinning tumble animation down and off-screen.
  - **Escape Outcome:**
    - Safely despawns when passing opposite screen border without breaking combos or deducting lives.
  - **Spawn Scheduling:**
    - Spawned via timer in `Board.gd` or `GameScreen.gd` (e.g. 1–2 times per level in levels 4+, or every 2000 points in Endless).

---

## 3. Automated Testing & Verification

1. **Test Coverage:**
   - `test_level_data.gd`: Verify all 15 campaign levels and endless config have valid $3\times2 \rightarrow 5\times3$ dimensions, durations, and quotas.
   - `test_board.gd` / `test_responsive.gd`: Verify $5\times3$ hole positioning, scale bounding, and hit test scaling.
   - `test_flying_rat.gd`: Verify flight trajectory, bounds checking, hit registration, powerup trigger, and despawn cleanup.
   - `test_mallet.gd` & `test_rat_fsm.gd`: Verify swing lifecycle, squash deformations, and state transitions.
2. **Headless Test Suite:** Run `make test` (all checks green).
3. **Audio & Level Generation:** Regenerate with `make levels` and `make audio`.

---

## 4. Git & PR Strategy

- Working branch: `feature/gameplay-graphics-overhaul` (created from `main`).
- Atomic commits per milestone.
- Remote push to `origin/feature/gameplay-graphics-overhaul`.
- Pull request raised against `main` via `gh pr create` with full description and test logs.
- Do NOT push to `main` and do NOT merge the PR (user responsibility).
