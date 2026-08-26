class_name TestCase
extends RefCounted
## Base for headless test modules. Subclasses define test_*() methods.

var errors: Array[String] = []
var checks := 0
var root: Window = null
var tree: SceneTree = null

func ok(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		errors.append(msg)

func fail(msg: String) -> void:
	ok(false, msg)

func eq(actual: Variant, expected: Variant, msg: String) -> void:
	checks += 1
	if actual != expected:
		errors.append("%s (expected %s, got %s)" % [msg, str(expected), str(actual)])
