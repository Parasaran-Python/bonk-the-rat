# BONK THE RAT! — Level Design & Progression Guide

## 1. Campaign Progression

The campaign consists of **15 hand-tuned levels** structured across **3 themed zones**. Each zone introduces new rat behaviors, tighter spawn rhythms, higher score quotas, and scaling grid layouts ($3\times2 \rightarrow 3\times3 \rightarrow 4\times3 \rightarrow 5\times3$).

### Zone 1: The Warm Pantry (Levels 1–5)
- **Theme:** Warm amber wood, pantry shelves, flour sacks.
- **Roster:** Normal Rats, Zoomer Rats, Clock Rats (Freeze Power-up), Tank Rats.
- **Difficulty:** Gentle curve introducing timing, multi-hit enemies, power-up utilization, and airborne bonus events.

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Max Concurrent | Introduced Mechanics |
|---|---|---|---|---|---|---|
| 01 | 3x2 | 45s | 700 / 1,300 / 2,000 | 1.40s -> 0.95s | 1 | Normal Rat |
| 02 | 3x2 | 50s | 1,100 / 1,900 / 2,900 | 1.30s -> 0.90s | 2 | Clock Rat (Freeze Power-up) |
| 03 | 3x2 | 50s | 1,600 / 2,700 / 4,000 | 1.20s -> 0.85s | 2 | Zoomer Rat |
| 04 | 3x3 | 55s | 2,100 / 3,500 / 5,200 | 1.15s -> 0.80s | 3 | Tank Rat (2 HP) & Flying Rat Events |
| 05 | 3x3 | 60s | 2,600 / 4,300 / 6,400 | 1.10s -> 0.75s | 3 | Zone 1 Climax |

---

### Zone 2: The Cold Basement (Levels 6–10)
- **Theme:** Cool slate blue stone, pipes, damp concrete.
- **Unlock Requirement:** Complete Level 5 with at least 1★.
- **Roster:** Tank Rats, Golden Rats (Bonus Points), Whiskers the Cat (Forbidden!), Star Rats (2x Multiplier).

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Max Concurrent | Introduced Mechanics |
|---|---|---|---|---|---|---|
| 06 | 3x3 | 55s | 3,200 / 5,200 / 7,600 | 1.05s -> 0.70s | 3 | Multi-enemy waves with Tank Rats |
| 07 | 3x3 | 55s | 3,800 / 6,100 / 8,900 | 1.00s -> 0.65s | 3 | Whiskers (Avoid!) & Star Rat (2x Points) |
| 08 | 3x3 | 60s | 4,500 / 7,200 / 10,500 | 0.95s -> 0.62s | 4 | Golden Rat (500 pts) |
| 09 | 4x3 | 60s | 5,400 / 8,600 / 12,500 | 0.92s -> 0.58s | 4 | 4x3 Grid expansion & Mixed Waves |
| 10 | 4x3 | 60s | 6,300 / 10,000 / 14,500 | 0.88s -> 0.54s | 4 | Zone 2 Climax |

---

### Zone 3: The Midnight Kitchen (Levels 11–15)
- **Theme:** Dark navy tiled floors, stainless steel counters, neon moonlit shadows.
- **Unlock Requirement:** Complete Level 10 with at least 1★.
- **Roster:** Full cast including Boom Rats (Bomb - Avoid!).

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Max Concurrent | Introduced Mechanics |
|---|---|---|---|---|---|---|
| 11 | 4x3 | 60s | 7,300 / 11,500 / 16,500 | 0.82s -> 0.50s | 5 | Boom Rat (Avoid!) |
| 12 | 4x3 | 60s | 8,300 / 13,000 / 18,500 | 0.78s -> 0.46s | 5 | High Density Spawns |
| 13 | 4x3 | 60s | 9,400 / 14,700 / 21,000 | 0.74s -> 0.42s | 5 | Chaos Mix |
| 14 | 5x3 | 65s | 11,000 / 17,000 / 24,000 | 0.70s -> 0.36s | 6 | 5x3 Grid (15 holes) & High Concurrency |
| 15 | 5x3 | 65s | 13,000 / 20,000 / 28,000 | 0.65s -> 0.30s | 7 | Grand Finale Frenzy |

---

## 2. Flying Rat Bonus Mechanic

- **Availability:** Spawns dynamically in Campaign levels (Level 4+) and periodically (every ~25s) in Endless mode.
- **Flight Behavior:** Glides horizontally across the upper third of the playfield ($Y \approx 140\text{px} \dots 180\text{px}$) along an oscillating sinusoidal trajectory:
  $$Y(t) = Y_0 + \sin(t \times 4.0) \times 28.0$$
- **Hit Detection:** Screen-space proximity detection (within 65px radius) during any mallet swing.
- **Reward:**
  - **+1,000 Bonus Points** directly added to score.
  - **Instant Power-Up Trigger:** Activates either a **Freeze** (5.0s) or **2x Score Multiplier** (7.0s) buff.
  - **Impact FX:** Emits confetti bursts, shockwave rings, and star pickup fanfare.

---

## 3. Endless Mode Mechanics

- **Unlock Condition:** Clear Zone 2 (Level 10 with $\ge$ 1★).
- **Rule Set:** 3 Lives, expansive **5x3 grid** (15 holes), no time limit.
- **Dynamic Wave Progression:**
  $$\text{wave} = 1 + \lfloor \frac{\text{score}}{2000} \rfloor$$
  $$\text{speed\_multiplier} = 1.0 + 0.12 \times (\text{wave} - 1)$$
- **Spawn Interval:** Dynamically scales faster with each wave threshold.
- **Periodic Glider Spawns:** Flying Rats appear every ~25 seconds to provide mid-run scoring opportunities and power-up recoveries.
- **Leaderboard:** Local Top-10 persistence with 8-character player initials and timestamp recording.

---

## 4. Re-generating Level Resources

Campaign level resources (`src/data/levels/level_01.tres` through `level_15.tres` and `endless.tres`) are generated deterministically:
```bash
make levels
```
