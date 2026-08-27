extends TestCase

func test_star_rating_instantiates_and_configures() -> void:
	var sr := StarRating.new(2, 20.0, 8.0)
	eq(sr.stars, 2, "rating starts at 2 stars")
	eq(sr.max_stars, 3, "max stars default 3")
	sr.stars = 5
	eq(sr.stars, 3, "clamped to max_stars")
	sr.stars = -2
	eq(sr.stars, 0, "clamped to 0")
	if root != null:
		root.add_child(sr)
	sr.queue_free()

func test_lives_display_instantiates_and_configures() -> void:
	var ld := LivesDisplay.new(3, 16.0)
	eq(ld.lives, 3, "lives starts at 3")
	eq(ld.max_lives, 3, "max lives default 3")
	ld.lives = 1
	eq(ld.lives, 1, "lives updated to 1")
	ld.lives = 10
	eq(ld.lives, 3, "clamped to max_lives")
	if root != null:
		root.add_child(ld)
	ld.queue_free()

func test_star_icon_instantiates() -> void:
	var si := StarIcon.new(16.0)
	eq(si.radius, 16.0, "radius configured")
	if root != null:
		root.add_child(si)
	si.queue_free()
