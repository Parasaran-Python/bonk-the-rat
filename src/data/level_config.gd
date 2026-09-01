class_name LevelConfig
extends Resource
## Data-only level definition. Defaults = level 1 values.

@export var level_id: int = 1
@export var duration_s: float = 45.0
@export var grid_columns: int = 3
@export var grid_rows: int = 2
@export var max_concurrent: int = 1
@export var spawn_interval_start: float = 1.40
@export var spawn_interval_end: float = 0.95
@export var rat_weights: Dictionary = {"norm": 95, "whiskers": 5}
@export var quota_star1: int = 700
@export var quota_star2: int = 1300
@export var quota_star3: int = 2000
@export var zone_theme: int = 1
@export var music_track: String = "zone1"

func interval_at(progress: float) -> float:
	return lerpf(spawn_interval_start, spawn_interval_end, clampf(progress, 0.0, 1.0))

func hole_count() -> int:
	return grid_columns * grid_rows
