extends TestCase

func test_mallet_swing_lifecycle() -> void:
	var mallet: Mallet = load("res://src/game/mallet.tscn").instantiate()
	if root != null:
		root.add_child(mallet)
	eq(mallet.is_swinging(), false, "mallet initially not swinging")
	mallet.swing_at(Vector2(400, 300))
	eq(mallet.global_position, Vector2(400, 300), "mallet position matches target")
	ok(mallet.is_swinging(), "mallet marked as swinging during strike")
	eq(mallet.rotation_degrees, -65.0, "anticipation angle starts at -65 deg")
	mallet.queue_free()

func test_mallet_retrigger_swing() -> void:
	var mallet: Mallet = load("res://src/game/mallet.tscn").instantiate()
	if root != null:
		root.add_child(mallet)
	mallet.swing_at(Vector2(100, 200))
	eq(mallet.global_position, Vector2(100, 200), "first swing pos")
	mallet.swing_at(Vector2(500, 400))
	eq(mallet.global_position, Vector2(500, 400), "second swing pos")
	ok(mallet.is_swinging(), "still swinging on second target")
	mallet.queue_free()


