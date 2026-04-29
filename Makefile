LOVE ?= love
APP_NAME := engaged-snake
BUILD_DIR := build
LOVE_FILE := $(BUILD_DIR)/$(APP_NAME).love

.PHONY: run love clean check

run:
	$(LOVE) .

love:
	mkdir -p $(BUILD_DIR)
	zip -9 -r $(LOVE_FILE) . \
		-x "*.git*" \
		-x "$(BUILD_DIR)/*" \
		-x ".codex/*"

clean:
	rm -rf $(BUILD_DIR)

check:
	find . -name '*.lua' ! -path './.git/*' ! -path './build/*' -print | sort | while read -r file; do \
		luac -p "$$file"; \
	done
