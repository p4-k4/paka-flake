#!/bin/bash
# Check if required arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <username> <home_path> <scripts_dir> <config_dir>"
    exit 1
fi
USERNAME="$1"
HOME_PATH="$2"
SCRIPTS_DIR="$3"
CONFIG_DIR="$4"

# Function to set up Zsh configuration
setup_zsh() {
    echo "Setting up Zsh configuration..."
    
    # Ensure the script has execute permissions for oh-my-zsh installation
    chmod +x "${SCRIPTS_DIR}/install-oh-my-zsh.sh"
    # Run the oh-my-zsh installation script
    "${SCRIPTS_DIR}/install-oh-my-zsh.sh" "$USERNAME" "$HOME_PATH"
    # Create ~/.config/zsh directory if it doesn't exist
    mkdir -p "$HOME_PATH/.config/zsh"
    # Copy the .zshrc file from the config directory to ~/.config/zsh
    cp "${CONFIG_DIR}/.zshrc" "$HOME_PATH/.config/zsh/.zshrc"
    chown "$USERNAME:staff" "$HOME_PATH/.config/zsh/.zshrc"
    # Create .zshenv in the home directory
    echo 'export ZDOTDIR="$HOME/.config/zsh"' > "$HOME_PATH/.zshenv"
    chown "$USERNAME:staff" "$HOME_PATH/.zshenv"
    echo "Zsh configuration setup completed."
}

# Function to set up Aerospace configuration
setup_aerospace() {
    echo "Setting up Aerospace configuration..."
    
    # Create ~/.config/aerospace directory if it doesn't exist
    mkdir -p "$HOME_PATH/.config/aerospace"
    # Copy the aerospace.toml file from the config directory to ~/.config/aerospace
    echo "Copying aerospace.toml from: ${CONFIG_DIR}"
    cp "${CONFIG_DIR}/aerospace/aerospace.toml" "$HOME_PATH/.config/aerospace/aerospace.toml"
    if [ $? -eq 0 ]; then
        chown "$USERNAME:staff" "$HOME_PATH/.config/aerospace/aerospace.toml"
        echo "Aerospace configuration setup completed."
    else
        echo "Error: Failed to copy aerospace.toml. Please check if the file exists in ${CONFIG_DIR}/aerospace/"
    fi
}

# Function to set up Flutter
setup_flutter() {
    echo "Setting up Flutter..."
    
    # Try to find Flutter installation
    FLUTTER_PATH=$(brew --prefix flutter 2>/dev/null)
    
    if [ -z "$FLUTTER_PATH" ]; then
        echo "Flutter not found via Homebrew. Checking common installation paths..."
        COMMON_PATHS=(
            "/opt/homebrew/Caskroom/flutter/latest/flutter"
            "/usr/local/Caskroom/flutter/latest/flutter"
            "$HOME/flutter"
        )
        
        for path in "${COMMON_PATHS[@]}"; do
            if [ -d "$path" ]; then
                FLUTTER_PATH="$path"
                break
            fi
        done
    fi
    
    if [ -z "$FLUTTER_PATH" ]; then
        echo "Flutter not found. Please ensure it's installed via Homebrew or manually."
        return 1
    fi
    
    echo "Flutter found at: $FLUTTER_PATH"
    
    # Add Flutter to PATH in .zshrc if not already present
    if ! grep -q "export PATH=.*flutter/bin" "$HOME_PATH/.config/zsh/.zshrc"; then
        echo "export PATH=\"\$PATH:$FLUTTER_PATH/bin\"" >> "$HOME_PATH/.config/zsh/.zshrc"
        echo "Added Flutter to PATH in .zshrc"
    else
        echo "Flutter already in PATH"
    fi
    
    # Switch to Flutter master channel and upgrade
    echo "Switching to Flutter master channel and upgrading..."
    $FLUTTER_PATH/bin/flutter channel master
    $FLUTTER_PATH/bin/flutter upgrade
    
    echo "Flutter setup completed. Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

# ... (rest of the script remains unchanged)

# Function to set up other configurations (placeholder for future additions)
setup_other_configs() {
    echo "Setting up other configurations..."
    # Add other configuration setup steps here
}

# Main execution
echo "Starting system configuration setup..."
setup_zsh
setup_aerospace
setup_flutter
setup_other_configs
echo "System configuration setup completed."
