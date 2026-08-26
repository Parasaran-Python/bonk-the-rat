GODOT ?= godot

.PHONY: run import test audio levels export-linux export-web export-android clean

run:
	$(GODOT) --path .

import:
	$(GODOT) --headless --import --path .

test: import
	$(GODOT) --headless --path . --script tests/run.gd

audio:
	$(GODOT) --headless --path . --script tools/generate_audio.gd

levels:
	$(GODOT) --headless --path . --script tools/generate_levels.gd

icons:
	$(GODOT) --headless --path . --script tools/generate_icons.gd

export-linux: import
	mkdir -p export/linux && $(GODOT) --headless --path . --export-release "Linux" export/linux/bonk-the-rat.x86_64

export-web: import
	mkdir -p export/web && $(GODOT) --headless --path . --export-release "Web" export/web/index.html

export-android: import
	mkdir -p export/android && $(GODOT) --headless --path . --export-debug "Android" export/android/bonk-the-rat.apk

clean:
	rm -rf export .godot
