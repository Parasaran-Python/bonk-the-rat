extends SceneTree

func _initialize() -> void:
	DirAccess.make_dir_absolute("res://icons")
	
	# Main 192x192
	var img_main := Image.create(192, 192, false, Image.FORMAT_RGBA8)
	img_main.fill(Color("264653"))
	# Fill central disc
	for y in range(192):
		for x in range(192):
			var d := Vector2(x - 96, y - 96).length()
			if d < 75.0:
				img_main.set_pixel(x, y, Color("e76f51"))
			elif d < 85.0:
				img_main.set_pixel(x, y, Color("f4a261"))
	img_main.save_png("res://icons/icon_main_192.png")

	# Background 432x432
	var img_bg := Image.create(432, 432, false, Image.FORMAT_RGBA8)
	img_bg.fill(Color("264653"))
	img_bg.save_png("res://icons/icon_background_432.png")

	# Foreground 432x432
	var img_fg := Image.create(432, 432, false, Image.FORMAT_RGBA8)
	img_fg.fill(Color(0, 0, 0, 0))
	for y in range(432):
		for x in range(432):
			var d := Vector2(x - 216, y - 216).length()
			if d < 140.0:
				img_fg.set_pixel(x, y, Color("e76f51"))
			elif d < 160.0:
				img_fg.set_pixel(x, y, Color("f4a261"))
	img_fg.save_png("res://icons/icon_foreground_432.png")

	# Monochrome 432x432
	var img_mono := Image.create(432, 432, false, Image.FORMAT_RGBA8)
	img_mono.fill(Color(0, 0, 0, 0))
	for y in range(432):
		for x in range(432):
			var d := Vector2(x - 216, y - 216).length()
			if d < 140.0:
				img_mono.set_pixel(x, y, Color.WHITE)
	img_mono.save_png("res://icons/icon_monochrome_432.png")

	print("Icons generated successfully in res://icons/")
	quit(0)
