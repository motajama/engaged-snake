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
		-x ".codex/*" \
		-x "backend/*"

clean:
	rm -rf $(BUILD_DIR)

check:
	find . -name '*.lua' ! -path './.git/*' ! -path './build/*' -print | sort | while read -r file; do \
		luac -p "$$file"; \
	done
	lua scripts/check_data.lua
	for file in tests/*_spec.lua; do \
		lua "$$file"; \
	done
	if command -v php >/dev/null 2>&1; then \
		find backend -name '*.php' -print | sort | while read -r file; do \
			php -l "$$file" >/dev/null; \
		done; \
	fi
