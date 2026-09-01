extends SceneTree
## godot --headless --path . --script tools/generate_levels.gd
## Regenerates res://src/data/levels/*.tres from the tuning table.

const LevelCfg := preload("res://src/data/level_config.gd")
const Prog := preload("res://src/logic/progression.gd")
const LEVELS_DIR := "res://src/data/levels"

## id, dur, cols, rows, conc, iv0, iv1, weights, q1, q2, q3
const TABLE := [
	[1, 45.0, 3, 2, 1, 1.40, 0.95, {"norm": 95, "whiskers": 5}, 700, 1300, 2000],
	[2, 50.0, 3, 2, 2, 1.30, 0.90, {"norm": 92, "whiskers": 7, "clock": 3}, 1100, 1900, 2900],
	[3, 50.0, 3, 2, 2, 1.20, 0.85, {"norm": 88, "zoomer": 6, "whiskers": 6}, 1600, 2700, 4000],
	[4, 55.0, 3, 3, 3, 1.15, 0.80, {"norm": 84, "zoomer": 8, "star": 4, "whiskers": 4}, 2100, 3500, 5200],
	[5, 60.0, 3, 3, 3, 1.10, 0.75, {"norm": 80, "zoomer": 10, "star": 4, "whiskers": 6}, 2600, 4300, 6400],
	[6, 55.0, 3, 3, 3, 1.05, 0.70, {"norm": 70, "zoomer": 12, "tank": 6, "whiskers": 6, "clock": 3}, 3200, 5200, 7600],
	[7, 55.0, 3, 3, 3, 1.00, 0.65, {"norm": 64, "zoomer": 13, "tank": 9, "star": 4, "whiskers": 6}, 3800, 6100, 8900],
	[8, 60.0, 3, 3, 4, 0.95, 0.62, {"norm": 58, "zoomer": 14, "tank": 11, "golden": 3, "whiskers": 6, "clock": 3}, 4500, 7200, 10500],
	[9, 60.0, 4, 3, 4, 0.92, 0.58, {"norm": 52, "zoomer": 15, "tank": 12, "golden": 4, "star": 4, "whiskers": 7}, 5400, 8600, 12500],
	[10, 60.0, 4, 3, 4, 0.88, 0.54, {"norm": 48, "zoomer": 15, "tank": 13, "golden": 5, "star": 4, "whiskers": 7, "clock": 3}, 6300, 10000, 14500],
	[11, 60.0, 4, 3, 5, 0.82, 0.50, {"norm": 44, "zoomer": 15, "tank": 12, "boom": 6, "golden": 5, "whiskers": 6, "star": 3}, 7300, 11500, 16500],
	[12, 60.0, 4, 3, 5, 0.78, 0.46, {"norm": 38, "zoomer": 16, "tank": 12, "boom": 7, "golden": 7, "whiskers": 7, "clock": 3}, 8300, 13000, 18500],
	[13, 60.0, 4, 3, 5, 0.74, 0.42, {"norm": 33, "zoomer": 17, "tank": 12, "boom": 8, "golden": 8, "whiskers": 7, "star": 3, "clock": 2}, 9400, 14700, 21000],
	[14, 65.0, 5, 3, 6, 0.70, 0.36, {"norm": 28, "zoomer": 18, "tank": 13, "boom": 8, "golden": 9, "whiskers": 8, "clock": 3}, 11000, 17000, 24000],
	[15, 65.0, 5, 3, 7, 0.65, 0.30, {"norm": 24, "zoomer": 18, "tank": 13, "boom": 8, "golden": 10, "whiskers": 8, "star": 3, "clock": 3}, 13000, 20000, 28000],
]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(LEVELS_DIR)
	var count := 0
	for row: Array in TABLE:
		count += _save_campaign(row)
	count += _save_endless()
	print("generated %d level resources in %s" % [count, LEVELS_DIR])
	quit(0)

func _save_campaign(row: Array) -> int:
	var id: int = row[0]
	var theme: int = Prog.zone_of(id)
	var cfg := LevelCfg.new()
	cfg.level_id = id
	cfg.duration_s = row[1]
	cfg.grid_columns = row[2]
	cfg.grid_rows = row[3]
	cfg.max_concurrent = row[4]
	cfg.spawn_interval_start = row[5]
	cfg.spawn_interval_end = row[6]
	cfg.rat_weights = row[7]
	cfg.quota_star1 = row[8]
	cfg.quota_star2 = row[9]
	cfg.quota_star3 = row[10]
	cfg.zone_theme = theme
	cfg.music_track = "zone%d" % theme
	var path := "%s/level_%02d.tres" % [LEVELS_DIR, id]
	_save(cfg, path)
	print("level_%02d.tres  dur=%.0fs grid=%dx%d conc=%d iv %.2f->%.2f quotas %d/%d/%d zone%d %s" % [
		id, cfg.duration_s, cfg.grid_columns, cfg.grid_rows, cfg.max_concurrent,
		cfg.spawn_interval_start, cfg.spawn_interval_end,
		cfg.quota_star1, cfg.quota_star2, cfg.quota_star3, theme, str(cfg.rat_weights)])
	return 1

func _save_endless() -> int:
	var cfg := LevelCfg.new()
	cfg.level_id = 0
	cfg.duration_s = 999999.0
	cfg.grid_columns = 5
	cfg.grid_rows = 3
	cfg.max_concurrent = 4
	cfg.spawn_interval_start = 0.90
	cfg.spawn_interval_end = 0.90
	cfg.rat_weights = {"norm": 70, "zoomer": 12, "tank": 8, "golden": 4, "whiskers": 6}
	cfg.quota_star1 = 0
	cfg.quota_star2 = 0
	cfg.quota_star3 = 0
	cfg.zone_theme = 3
	cfg.music_track = "endless"
	var path := "%s/endless.tres" % LEVELS_DIR
	_save(cfg, path)
	print("endless.tres    dur=%.0fs grid=%dx%d conc=%d iv flat 0.90 zone3 %s" % [
		cfg.duration_s, cfg.grid_columns, cfg.grid_rows, cfg.max_concurrent, str(cfg.rat_weights)])
	return 1

func _save(cfg: LevelCfg, path: String) -> void:
	var err := ResourceSaver.save(cfg, path)
	if err != OK:
		push_error("failed to save %s (code %d)" % [path, err])
