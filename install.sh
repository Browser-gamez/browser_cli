#!/bin/bash

# Browser Games Manager Installer
# This will install the tool globally on your system

set -e

echo "🎮 Installing Browser Games Manager..."
echo "======================================"

# Check for sudo if needed
if [ "$EUID" -ne 0 ]; then
    echo "⚠ Running as non-root. Will install to user directory."
    INSTALL_DIR="$HOME/.local/bin"
    SYSTEM_INSTALL=false
else
    INSTALL_DIR="/usr/local/bin"
    SYSTEM_INSTALL=true
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download or copy the script
SCRIPT_URL="https://raw.githubusercontent.com/Browser-gamez/main/main/browser-games"
SCRIPT_NAME="browser-games"

echo "📦 Downloading browser-games script..."

if command -v curl >/dev/null 2>&1; then
    if curl -sL "$SCRIPT_URL" -o "/tmp/$SCRIPT_NAME"; then
        echo "✓ Script downloaded successfully"
    else
        echo "⚠ Could not download from GitHub. Using local file if available."
        if [ -f "browser-games" ]; then
            cp "browser-games" "/tmp/$SCRIPT_NAME"
        else
            echo "❌ No script file found. Please download it first."
            exit 1
        fi
    fi
elif [ -f "browser-games" ]; then
    cp "browser-games" "/tmp/$SCRIPT_NAME"
else
    echo "❌ Neither curl nor local script found. Please install curl or download the script."
    exit 1
fi

# Make script executable
chmod +x "/tmp/$SCRIPT_NAME"

# Install to target directory
echo "📁 Installing to $INSTALL_DIR..."
cp "/tmp/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"

# Create configuration directory
CONFIG_DIR="$HOME/.browser-games"
mkdir -p "$CONFIG_DIR"

# Create desktop entry (optional)
if [ -d "$HOME/.local/share/applications" ]; then
    echo "📋 Creating desktop entry..."
    cat > "$HOME/.local/share/applications/browser-games.desktop" << EOF
[Desktop Entry]
Name=Browser Games Manager
Comment=Manage and play browser games
Exec=browser-games shell
Icon=applications-games
Terminal=true
Type=Application
Categories=Game;
Keywords=games;browser;html5;
EOF
fi

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "📝 Adding to PATH..."
    
    SHELL_CONFIG=""
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.profile" ]; then
        SHELL_CONFIG="$HOME/.profile"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Browser Games Manager" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_CONFIG"
        echo "✓ Added to $SHELL_CONFIG"
        echo "⚠ Please restart your terminal or run: source $SHELL_CONFIG"
    else
        echo "⚠ Could not find shell config file. Please add $INSTALL_DIR to your PATH manually."
    fi
fi

echo ""
echo "======================================"
echo "✅ Installation complete!"
echo ""
echo "🚀 Usage:"
echo "   browser-games              # Start interactive shell"
echo "   browser-games install sample-game  # Install sample game"
echo "   browser-games start sample-game    # Play sample game"
echo ""
echo "📂 Games will be stored in: $CONFIG_DIR"
echo "🔧 Configuration: $CONFIG_DIR/config.json"
echo ""
echo "Need help? Run: browser-games help"
echo "======================================"
