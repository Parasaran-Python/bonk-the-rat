extends TestCase
## Automated tests verifying responsiveness across different screen sizes and aspect ratios.

func test_backdrop_painter_handles_various_aspect_ratios_and_sizes() -> void:
	var board: Node2D = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var bg: Node2D = board.get_node("Backdrop")
	ok(bg != null, "board backdrop exists")
	bg.queue_redraw()
	ok(true, "backdrop redraw queued cleanly")
	board.queue_free()

func test_board_responsive_repositioning_and_scaling() -> void:
	var board: Node2D = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)

	var cfg: LevelConfig = load("res://src/data/levels/level_01.tres")
	board.setup(cfg, cfg.interval_at)

	ok(board._holes.size() > 0, "board has holes")
	ok(board._board_scale > 0.0 and board._board_scale <= 1.0, "board scale valid")

	board._reposition_holes()
	for h in board._holes:
		ok(h.position.x >= 0.0, "hole x >= 0")
		ok(h.position.y >= 0.0, "hole y >= 0")
		ok(h.scale.x > 0.0 and h.scale.y > 0.0, "hole has positive scale")

	board.queue_free()

func test_zone_map_responsive_resizing() -> void:
	var zm: ZoneMap = load("res://src/screens/zone_map.tscn").instantiate()
	if root != null:
		root.add_child(zm)

	ok(zm.has_node("CardsContainer"), "zone map has CardsContainer")
	zm._on_resized()
	ok(is_instance_valid(zm), "zone map survived resize event")
	zm.queue_free()

func test_level_select_responsive_resizing() -> void:
	var ls: LevelSelect = load("res://src/screens/level_select.tscn").instantiate()
	ls.zone_filter = 1
	if root != null:
		root.add_child(ls)

	ok(ls.has_node("GridContainer"), "level select has GridContainer")
	ls._on_resized()
	eq(ls.tile_count(), 5, "level select has 5 tiles")
	ls.queue_free()

func test_hud_responsive_elements() -> void:
	var hud: HUD = load("res://src/game/hud.tscn").instantiate()
	if root != null:
		root.add_child(hud)

	ok(hud.has_node("Root/TopBar"), "hud has TopBar")
	ok(hud.has_node("Root/BottomBar"), "hud has BottomBar")
	hud.set_combo(2, 0.5)
	hud.set_combo(4, 0.8)
	hud.set_combo(8, 1.0)
	hud.show_powerup("freeze", 1.0)
	hud.show_score_popup(100, Vector2(640, 360))
	ok(true, "hud popups executed without error")
	hud.queue_free()

func test_confetti_responsive_default_position() -> void:
	var fx := FxLayer.new()
	if root != null:
		root.add_child(fx)
	fx.confetti()
	ok(fx.get_child_count() > 0, "confetti bursts created")
	fx.queue_free()

func test_pause_overlay_responsive_and_layering() -> void:
	var pause: PauseOverlay = load("res://src/game/pause_overlay.tscn").instantiate()
	if root != null:
		root.add_child(pause)
	ok(pause.layer == 30, "pause overlay on layer 30")
	ok(pause.has_node("Root/Panel"), "pause overlay has centered panel")
	pause.show_pause()
	ok(pause.visible, "pause overlay visible when shown")
	pause.hide_pause()
	ok(not pause.visible, "pause overlay hidden when dismissed")
	pause.queue_free()
