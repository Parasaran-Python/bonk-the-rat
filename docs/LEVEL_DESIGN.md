# BONK THE RAT! — Level Design & Progression Guide

## 1. Campaign Progression

The campaign consists of **15 hand-tuned levels** structured across **3 themed zones**. Each zone introduces new rat behaviors, tighter spawn rhythms, and higher score quotas.

### Zone 1: The Warm Pantry (Levels 1–5)
- **Theme:** Warm amber wood, pantry shelves, flour sacks.
- **Roster:** Normal Rats, Zoomer Rats, Clock Rats (Freeze Power-up).
- **Difficulty:** Gentle curve introducing timing and power-up utilization.

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Introduced Species |
|-------|------|----------|-------------------|----------------|-------------------|
| 01 | 3x2 | 30s | 500 / 1000 / 1500 | 1.4s -> 1.0s | Normal Rat |
| 02 | 3x2 | 35s | 800 / 1600 / 2400 | 1.3s -> 0.9s | Zoomer Rat |
| 03 | 3x2 | 40s | 1200 / 2400 / 3600 | 1.2s -> 0.8s | Clock Rat (Freeze) |
| 04 | 3x3 | 45s | 1800 / 3600 / 5400 | 1.1s -> 0.75s | Tank Rat (2 HP) |
| 05 | 3x3 | 50s | 2500 / 5000 / 7500 | 1.0s -> 0.65s | Zone 1 Climax |

---

### Zone 2: The Cold Basement (Levels 6–10)
- **Theme:** Cool slate blue stone, pipes, damp concrete.
- **Unlock Requirement:** Complete Level 5 with at least 1★.
- **Roster:** Tank Rats, Golden Rats (Bonus Points), Whiskers the Cat (Forbidden!).

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Introduced Species |
|-------|------|----------|-------------------|----------------|-------------------|
| 06 | 3x3 | 40s | 1500 / 3000 / 4500 | 1.1s -> 0.75s | Golden Rat (500 pts) |
| 07 | 3x3 | 45s | 2000 / 4000 / 6000 | 1.0s -> 0.70s | Whiskers (Avoid!) |
| 08 | 4x3 | 45s | 2600 / 5200 / 7800 | 0.95s -> 0.65s | Star Rat (2x Points) |
| 09 | 4x3 | 50s | 3200 / 6400 / 9600 | 0.90s -> 0.60s | Fast Mixed Waves |
| 10 | 4x3 | 55s | 4000 / 8000 / 12000 | 0.85s -> 0.55s | Zone 2 Climax |

---

### Zone 3: The Midnight Kitchen (Levels 11–15)
- **Theme:** Dark navy tiled floors, stainless steel counters, neon moonlit shadows.
- **Unlock Requirement:** Complete Level 10 with at least 1★.
- **Roster:** Full cast including Boom Rats (Bomb - Avoid!).

| Level | Grid | Duration | Target 1★ / 2★ / 3★ | Spawn Interval | Introduced Species |
|-------|------|----------|-------------------|----------------|-------------------|
| 11 | 4x3 | 45s | 3000 / 6000 / 9000 | 0.85s -> 0.55s | Boom Rat (Avoid!) |
| 12 | 4x3 | 50s | 3800 / 7600 / 11400 | 0.80s -> 0.50s | High Density Spawns |
| 13 | 4x3 | 50s | 4600 / 9200 / 13800 | 0.75s -> 0.45s | Chaos Mix |
| 14 | 4x3 | 55s | 5500 / 11000 / 16500 | 0.70s -> 0.40s | Frenzy Speed |
| 15 | 4x3 | 60s | 7000 / 14000 / 21000 | 0.65s -> 0.35s | Grand Finale |

---

## 2. Endless Mode Mechanics

- **Unlock Condition:** Clear Zone 2 (Level 10 with >= 1★).
- **Rule Set:** 3 Lives, 4x3 grid, no time limit.
- **Dynamic Wave Progression:**
  $$\text{wave} = 1 + \lfloor \frac{\text{score}}{2000} \rfloor$$
  $$\text{speed\_multiplier} = 1.0 + 0.12 \times (\text{wave} - 1)$$
- **Spawn Interval:** Dynamically scales faster with each wave threshold.
- **Leaderboard:** Local Top-10 persistence with 8-character player initials and timestamp recording.

---

## 3. Re-generating Level Resources

Campaign level resources (`src/data/levels/level_01.tres` through `level_15.tres` and `endless.tres`) are generated deterministically:
```bash
make levels
```
