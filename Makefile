.PHONY: build clean install uninstall open enable-extension help

PROJECT_NAME = Video2PPT
PROJECT_DIR = ./Video2PPT
BUILD_DIR = $(PROJECT_DIR)/build
APP_NAME = $(PROJECT_NAME).app
APP_PATH = $(BUILD_DIR)/Build/Products/Release/$(APP_NAME)
INSTALL_PATH = /Applications/$(APP_NAME)

help:
	@echo "Video2PPT macOS Extension Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make build          - Build the app and extension"
	@echo "  make install        - Install to /Applications"
	@echo "  make uninstall      - Remove from /Applications"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make open           - Open the installed app"
	@echo "  make enable-extension - Open extension settings"
	@echo "  make all            - Build and install"
	@echo ""

build:
	@echo "Building $(PROJECT_NAME)..."
	@xcodebuild -project $(PROJECT_DIR)/$(PROJECT_NAME).xcodeproj \
		-scheme $(PROJECT_NAME) \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR) \
		clean build
	@echo "Build complete!"

install: build
	@echo "Installing to $(INSTALL_PATH)..."
	@sudo cp -r $(APP_PATH) $(INSTALL_PATH)
	@echo "Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Run 'make open' to launch the app"
	@echo "2. Run 'make enable-extension' to enable in System Settings"

uninstall:
	@echo "Uninstalling $(APP_NAME)..."
	@sudo rm -rf $(INSTALL_PATH)
	@echo "Uninstalled successfully!"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

open:
	@echo "Opening $(APP_NAME)..."
	@open $(INSTALL_PATH)

enable-extension:
	@echo "Opening System Settings Extensions..."
	@open "x-apple.systempreferences:com.apple.preference.security?Privacy_Extensions"
	@echo ""
	@echo "Please enable 'Video2PPT Extension' in Finder Extensions"

all: build install
	@echo ""
	@echo "$(PROJECT_NAME) has been built and installed!"
	@echo "Run 'make open' to launch the app"
	@echo "Run 'make enable-extension' to enable the Finder extension"