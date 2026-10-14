PLUGIN_ID := com.keyaruga.applicationgroup
PACKAGE_TYPE := Plasma/Applet

SRC_DIR := src
DIST_DIR := dist

METADATA := $(SRC_DIR)/metadata.json
VERSION := $(shell sed -n 's/.*"Version":[[:space:]]*"\([^"]*\)".*/\1/p' $(METADATA) | head -n 1)
PACKAGE := $(DIST_DIR)/application-group-$(VERSION).zip

PLASMOID := $(shell which plasmawindowed 2>/dev/null || which plasmoidviewer 2>/dev/null || echo plasmawindowed)
KPACKAGE := kpackagetool6

ICON_NAME := $(PLUGIN_ID)
ICON_SRC := $(SRC_DIR)/contents/icons
ICON_DEST := $(HOME)/.local/share/icons/hicolor

.PHONY: help run install upgrade reinstall uninstall package check version clean install-icons uninstall-icons

help:
	@echo "Application Group — KDE Plasma 6 Plasmoid"
	@echo
	@echo "Usage:"
	@echo "  make run        Install/upgrade and run with $(PLASMOID)"
	@echo "  make install    Install the Plasmoid and icons"
	@echo "  make upgrade    Upgrade the installed Plasmoid and icons"
	@echo "  make reinstall  Remove and install fresh"
	@echo "  make uninstall  Remove the Plasmoid and icons"
	@echo "  make package    Create KDE Store package in dist/"
	@echo "  make check      Check project structure and files"
	@echo "  make version    Show current version"
	@echo "  make clean      Remove generated files"
	@echo

run: upgrade
	$(PLASMOID) $(PLUGIN_ID)

install-icons:
	@mkdir -p "$(ICON_DEST)/256x256/apps" "$(ICON_DEST)/128x128/apps" "$(ICON_DEST)/64x64/apps" "$(ICON_DEST)/48x48/apps" "$(ICON_DEST)/32x32/apps"
	@cp -f "$(ICON_SRC)/com.keyaruga.applicationgroup.png" "$(ICON_DEST)/256x256/apps/$(ICON_NAME).png"
	@cp -f "$(ICON_SRC)/128x128.png" "$(ICON_DEST)/128x128/apps/$(ICON_NAME).png"
	@cp -f "$(ICON_SRC)/64x64.png" "$(ICON_DEST)/64x64/apps/$(ICON_NAME).png"
	@cp -f "$(ICON_SRC)/48x48.png" "$(ICON_DEST)/48x48/apps/$(ICON_NAME).png"
	@cp -f "$(ICON_SRC)/32x32.png" "$(ICON_DEST)/32x32/apps/$(ICON_NAME).png"
	@-gtk-update-icon-cache -q -t "$(ICON_DEST)" 2>/dev/null || true

uninstall-icons:
	@rm -f "$(ICON_DEST)/"*/apps/"$(ICON_NAME).png"
	@-gtk-update-icon-cache -q -t "$(ICON_DEST)" 2>/dev/null || true

install: install-icons
	$(KPACKAGE) --type $(PACKAGE_TYPE) --install "$(SRC_DIR)"

upgrade: install-icons
	-$(KPACKAGE) --type $(PACKAGE_TYPE) --upgrade "$(SRC_DIR)" || $(KPACKAGE) --type $(PACKAGE_TYPE) --install "$(SRC_DIR)"

reinstall: uninstall
	$(MAKE) install

uninstall: uninstall-icons
	$(KPACKAGE) --type $(PACKAGE_TYPE) --remove $(PLUGIN_ID)

package: check
	@mkdir -p "$(DIST_DIR)"
	@rm -f "$(PACKAGE)"
	@cd "$(SRC_DIR)" && zip -qr "../$(PACKAGE)" metadata.json contents
	@echo "Package created: $(PACKAGE)"

check:
	@test -f "$(METADATA)" || \
		(echo "ERROR: $(METADATA) not found"; exit 1)
	@test -d "$(SRC_DIR)/contents" || \
		(echo "ERROR: $(SRC_DIR)/contents/ not found"; exit 1)
	@test -d "$(SRC_DIR)/contents/config" || \
		(echo "ERROR: $(SRC_DIR)/contents/config/ not found"; exit 1)
	@test -d "$(SRC_DIR)/contents/ui" || \
		(echo "ERROR: $(SRC_DIR)/contents/ui/ not found"; exit 1)
	@test -d "$(SRC_DIR)/contents/icons" || \
		(echo "ERROR: $(SRC_DIR)/contents/icons/ not found"; exit 1)
	@test -f "$(SRC_DIR)/contents/ui/main.qml" || \
		(echo "ERROR: $(SRC_DIR)/contents/ui/main.qml not found"; exit 1)
	@test -f "$(SRC_DIR)/contents/config/main.xml" || \
		(echo "ERROR: $(SRC_DIR)/contents/config/main.xml not found"; exit 1)
	@echo "Project structure: OK"

version:
	@echo "$(VERSION)"

clean:
	@rm -rf "$(DIST_DIR)"
	@echo "Cleaned generated files."
