extends TestCase

func test_submit_returns_rank_and_persists() -> void:
	var sm: Node = root.get_node("SaveManager") if root != null and root.has_node("SaveManager") else null
	if sm == null:
		sm = load("res://src/autoload/save_manager.gd").new()
	sm.reset_all()

	# Fill with 10 high scores: 100, 150, 200, ..., 550
	for i in range(10):
		sm.submit_endless("BOT", 100 + i * 50)

	var r: int = sm.submit_endless("ZZZ", 260)
	eq(r, 7, "260 is rank 7")
	eq(sm.top_ten().size(), 10, "board remains capped at 10")
	var unplaced: int = sm.submit_endless("LOW", 1)
	eq(unplaced, 0, "unplaced returns 0")

func test_endless_gate_in_ui_state() -> void:
	ok(Progression.endless_unlocked({6: 1, 7: 1, 8: 1, 9: 1, 10: 1}), "gate open state")
	ok(not Progression.endless_unlocked({}), "gate closed fresh")
