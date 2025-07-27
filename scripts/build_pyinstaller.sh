#!/bin/bash

# PyInstaller build script for ClaudeWarp GUI application
# This script creates a standalone GUI executable with PySide6

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project settings
PROJECT_NAME="claudewarp"
MAIN_SCRIPT="main.py"
BUILD_DIR="build"
DIST_DIR="dist"
SPEC_FILE="${PROJECT_NAME}.spec"

# Get project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== ClaudeWarp GUI PyInstaller Build Script ===${NC}"
echo -e "${BLUE}Project root: ${PROJECT_ROOT}${NC}"

# Change to project root
cd "$PROJECT_ROOT"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR" "$DIST_DIR" "$SPEC_FILE"

# Install GUI dependencies and PyInstaller
echo -e "${YELLOW}Installing GUI dependencies...${NC}"
uv add --dev pyinstaller
uv sync --group gui

# Create optimized PyInstaller command for GUI
echo -e "${YELLOW}Building GUI application with PyInstaller...${NC}"

# Detect operating system and set appropriate PyInstaller options
OS_TYPE=$(uname -s)
echo -e "${BLUE}Operating System: $OS_TYPE${NC}"

if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS - create .app bundle
    echo -e "${BLUE}Configuring for macOS .app bundle...${NC}"
    PYINSTALLER_OPTS=(
        --name="ClaudeWarp"
        --onedir
        --windowed
        --clean
        --noconfirm
        --optimize=2
        --icon="claudewarp/gui/resources/icons/claudewarp.ico"
    )
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Linux - create single executable with GUI support
    echo -e "${BLUE}Configuring for Linux executable...${NC}"
    PYINSTALLER_OPTS=(
        --name="$PROJECT_NAME"
        --onefile
        --windowed
        --clean
        --noconfirm
        --optimize=2
        --icon="claudewarp/gui/resources/icons/claudewarp.ico"
    )
else
    # Windows/Other - create single executable
    echo -e "${BLUE}Configuring for single executable...${NC}"
    PYINSTALLER_OPTS=(
        --name="$PROJECT_NAME"
        --onefile
        --windowed
        --clean
        --noconfirm
        --optimize=2
        --icon="claudewarp/gui/resources/icons/claudewarp.ico"
    )
fi

# Common PyInstaller options
COMMON_OPTS=(
    --exclude-module=tkinter
    --exclude-module=matplotlib
    --exclude-module=numpy
    --exclude-module=scipy
    --exclude-module=pandas
    --exclude-module=jupyter
    --exclude-module=IPython
    --hidden-import=toml
    --hidden-import=rich
    --hidden-import=colorlog
    --hidden-import=typer
    --hidden-import=pydantic
    --hidden-import=PySide6.QtCore
    --hidden-import=PySide6.QtGui
    --hidden-import=PySide6.QtWidgets
    --hidden-import=qfluentwidgets
    --hidden-import=claudewarp.gui
    --hidden-import=claudewarp.gui.app
    --hidden-import=claudewarp.gui.main_window
    --hidden-import=claudewarp.gui.dialogs
    --hidden-import=claudewarp.cli
    --hidden-import=claudewarp.core
    --hidden-import=claudewarp.cli.main
    --hidden-import=claudewarp.cli.commands
    --hidden-import=claudewarp.cli.formatters
    --hidden-import=claudewarp.core.config
    --hidden-import=claudewarp.core.manager
    --hidden-import=claudewarp.core.models
    --hidden-import=claudewarp.core.utils
    --hidden-import=claudewarp.core.exceptions
    --add-data="claudewarp:claudewarp"
    --add-data="claudewarp/gui/resources:claudewarp/gui/resources"
    --distpath="$DIST_DIR"
    --workpath="$BUILD_DIR"
    --specpath="."
)

# Combine all options
ALL_OPTS=("${PYINSTALLER_OPTS[@]}" "${COMMON_OPTS[@]}")

uv run pyinstaller "${ALL_OPTS[@]}" "$MAIN_SCRIPT"

# Check if build was successful
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS - check for .app bundle
    if [ -d "$DIST_DIR/ClaudeWarp.app" ]; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        EXECUTABLE="$DIST_DIR/ClaudeWarp.app"
        echo -e "${GREEN}📦 App bundle created: $EXECUTABLE${NC}"
        
        # Show app bundle structure
        echo -e "${BLUE}=== App Bundle Structure ===${NC}"
        ls -la "$EXECUTABLE/Contents/"
        
        # Get bundle size
        BUNDLE_SIZE=$(du -sh "$EXECUTABLE" | cut -f1)
        echo -e "${GREEN}📦 Bundle size: $BUNDLE_SIZE${NC}"
        echo -e "${GREEN}📍 Location: $EXECUTABLE${NC}"
        
        # Analyze bundle contents for size optimization
        echo -e "${BLUE}=== Bundle Size Analysis ===${NC}"
        echo "Top 10 largest directories in bundle:"
        du -sh "$EXECUTABLE/Contents"/*/* 2>/dev/null | sort -hr | head -10 || echo "Could not analyze bundle contents"
        
        # Check for common size issues
        if [ -d "$EXECUTABLE/Contents/Resources" ]; then
            echo "Resources directory size:"
            du -sh "$EXECUTABLE/Contents/Resources" 2>/dev/null || echo "Could not check Resources size"
        fi
        
        if [ -d "$EXECUTABLE/Contents/Frameworks" ]; then
            echo "Frameworks directory size:"
            du -sh "$EXECUTABLE/Contents/Frameworks" 2>/dev/null || echo "Could not check Frameworks size"
            echo "Top 5 largest frameworks:"
            du -sh "$EXECUTABLE/Contents/Frameworks"/* 2>/dev/null | sort -hr | head -5 || echo "Could not analyze frameworks"
        fi
        
        echo -e "${GREEN}✅ macOS app bundle created successfully!${NC}"
        echo -e "${GREEN}You can run the app with: open $EXECUTABLE${NC}"
        
    else
        echo -e "${RED}❌ Build failed! ClaudeWarp.app not found${NC}"
        echo -e "${RED}Check the output above for errors.${NC}"
        ls -la "$DIST_DIR/"
        exit 1
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Linux - check for executable
    if [ -f "$DIST_DIR/$PROJECT_NAME" ]; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        
        EXECUTABLE="$DIST_DIR/$PROJECT_NAME"
        
        # Get file size
        FILE_SIZE=$(du -h "$EXECUTABLE" | cut -f1)
        echo -e "${GREEN}📦 Executable size: $FILE_SIZE${NC}"
        echo -e "${GREEN}📍 Location: $EXECUTABLE${NC}"
        
        # Check if executable has GUI dependencies
        echo -e "${BLUE}=== Checking GUI Dependencies ===${NC}"
        if ldd "$EXECUTABLE" 2>/dev/null | grep -q "libQt\|libPySide"; then
            echo -e "${GREEN}✅ GUI dependencies found${NC}"
        else
            echo -e "${YELLOW}⚠️ No Qt/PySide dependencies found in ldd output${NC}"
        fi
        
        echo -e "${GREEN}✅ Linux executable created successfully!${NC}"
        echo -e "${GREEN}You can run the application with: $EXECUTABLE${NC}"
        
    else
        echo -e "${RED}❌ Build failed! $PROJECT_NAME executable not found${NC}"
        echo -e "${RED}Check the output above for errors.${NC}"
        ls -la "$DIST_DIR/"
        exit 1
    fi
else
    # Windows/Other - check for executable
    if [ -f "$DIST_DIR/$PROJECT_NAME" ] || [ -f "$DIST_DIR/$PROJECT_NAME.exe" ]; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        
        # Find the actual executable
        EXECUTABLE="$DIST_DIR/$PROJECT_NAME"
        if [ -f "$DIST_DIR/$PROJECT_NAME.exe" ]; then
            EXECUTABLE="$DIST_DIR/$PROJECT_NAME.exe"
        fi
        
        # Get file size
        FILE_SIZE=$(du -h "$EXECUTABLE" | cut -f1)
        echo -e "${GREEN}📦 Executable size: $FILE_SIZE${NC}"
        echo -e "${GREEN}📍 Location: $EXECUTABLE${NC}"
        
        echo -e "${GREEN}✅ Executable created successfully!${NC}"
        echo -e "${GREEN}You can run the application with: $EXECUTABLE${NC}"
        
    else
        echo -e "${RED}❌ Build failed!${NC}"
        echo -e "${RED}Check the output above for errors.${NC}"
        exit 1
    fi
fi

# Create portable package based on OS
echo -e "${YELLOW}Creating portable package...${NC}"
PACKAGE_NAME="${PROJECT_NAME}-$(uname -s)-$(uname -m)"
PACKAGE_DIR="$DIST_DIR/$PACKAGE_NAME"

mkdir -p "$PACKAGE_DIR"

if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS - copy .app bundle
    if [ -d "$DIST_DIR/ClaudeWarp.app" ]; then
        cp -r "$DIST_DIR/ClaudeWarp.app" "$PACKAGE_DIR/"
        EXECUTABLE_NAME="ClaudeWarp.app"
        USAGE_INSTRUCTION="Double-click ClaudeWarp.app to launch the GUI application"
    else
        echo -e "${RED}ClaudeWarp.app not found for packaging${NC}"
        exit 1
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Linux - copy executable
    if [ -f "$DIST_DIR/$PROJECT_NAME" ]; then
        cp "$DIST_DIR/$PROJECT_NAME" "$PACKAGE_DIR/"
        EXECUTABLE_NAME="$PROJECT_NAME"
        USAGE_INSTRUCTION="Run ./$PROJECT_NAME to launch the GUI application"
    else
        echo -e "${RED}$PROJECT_NAME executable not found for packaging${NC}"
        exit 1
    fi
else
    # Windows/Other - copy executable
    if [ -f "$DIST_DIR/$PROJECT_NAME" ]; then
        cp "$DIST_DIR/$PROJECT_NAME" "$PACKAGE_DIR/"
        EXECUTABLE_NAME="$PROJECT_NAME"
        USAGE_INSTRUCTION="Run ./$PROJECT_NAME to launch the GUI application"
    elif [ -f "$DIST_DIR/$PROJECT_NAME.exe" ]; then
        cp "$DIST_DIR/$PROJECT_NAME.exe" "$PACKAGE_DIR/"
        EXECUTABLE_NAME="$PROJECT_NAME.exe"
        USAGE_INSTRUCTION="Run $PROJECT_NAME.exe to launch the GUI application"
    else
        echo -e "${RED}Executable not found for packaging${NC}"
        exit 1
    fi
fi

cp README.md "$PACKAGE_DIR/" 2>/dev/null || echo "README.md not found, skipping..."
cp LICENSE "$PACKAGE_DIR/" 2>/dev/null || echo "LICENSE not found, skipping..."

# Create a GUI-specific usage file
cat > "$PACKAGE_DIR/USAGE.txt" << EOF
ClaudeWarp GUI Application

This is the graphical user interface version of ClaudeWarp.

Usage:
  $USAGE_INSTRUCTION
  
Features:
  - Manage Claude API proxy servers
  - Add, edit, and delete proxy configurations
  - Switch between different proxies
  - Export settings for Claude Code integration
  - Visual status indicators and notifications

For command-line usage, please download the CLI version instead.
EOF

echo -e "${GREEN}📦 Portable package created: $PACKAGE_DIR${NC}"

echo -e "${BLUE}=== Build Summary ===${NC}"
if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo -e "${BLUE}App Bundle: $DIST_DIR/ClaudeWarp.app${NC}"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo -e "${BLUE}Executable: $DIST_DIR/$PROJECT_NAME${NC}"
else
    echo -e "${BLUE}Executable: $EXECUTABLE${NC}"
fi
echo -e "${BLUE}Package: $PACKAGE_DIR${NC}"
echo -e "${GREEN}Application ready for distribution! 🎉${NC}"