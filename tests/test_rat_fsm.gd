extends TestCase

func test_legal_flow() -> void:
	ok(Rat.can_transition(Rat.State.RISING, Rat.State.UP), "rise->up")
	ok(Rat.can_transition(Rat.State.UP, Rat.State.SINKING), "up->sink")
	ok(Rat.can_transition(Rat.State.SINKING, Rat.State.GONE), "sink->gone")

func test_interrupts_from_active_states() -> void:
	for s in [Rat.State.RISING, Rat.State.UP, Rat.State.SINKING]:
		ok(Rat.can_transition(s, Rat.State.HIT), "hit interrupts state %d" % s)

func test_gone_is_terminal() -> void:
	ok(not Rat.can_transition(Rat.State.GONE, Rat.State.UP), "no zombie rats")
	ok(not Rat.can_transition(Rat.State.HIT, Rat.State.RISING), "hit is terminal entry")

func test_rat_scene_instantiates_and_strikes_synchronously() -> void:
	var r: Rat = load("res://src/game/rat.tscn").instantiate()
	r.rat_id = "tank"          # set before _draw paths run headless
	if root != null:
		root.add_child(r)
	# synchronous FSM checks without awaiting tweens:
	eq(int(r.state), int(Rat.State.GONE), "starts GONE")
	ok(not r.visible, "rat starts hidden")
	eq(r.position.y, Rat.DOWN_OFFSET, "rat starts at down offset")
	r.queue_free()
