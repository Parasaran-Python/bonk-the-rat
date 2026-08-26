extends TestCase

func test_math_and_recording() -> void:
	ok(true, "never fires")
	eq(1 + 1, 2, "math works")
	eq(errors.size(), 0, "no errors yet")
