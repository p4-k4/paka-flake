#!/bin/bash
# Check if required arguments are provided
if [ "$#" -ne 5 ];
then
echo "Usage: $0 <username> <home_path> <scripts_dir> <config_dir> <wallpaper_path>"
exit 1
fi
USERNAME="$1"
         HOME_PATH="$2"
                   SCRIPTS_DIR="$3"
                               CONFIG_DIR="$4"
                                       WALLPAPER_PATH="$5"

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

# Add Homebrew to PATH
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME_PATH/.config/zsh/.zshrc"
	        echo "Added Homebrew to PATH in .zshrc"

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
	if [ $? -eq 0 ];
	then
	chown "$USERNAME:staff" "$HOME_PATH/.config/aerospace/aerospace.toml"
	echo "Aerospace configuration setup completed."
	else
		echo "Error: Failed to copy aerospace.toml. Please check if the file exists in ${CONFIG_DIR}/aerospace/"
		fi
	}

# Function to set up Flutter and its dependencies
setup_flutter() {
    echo "Setting up Flutter and its dependencies..."
    
    # Check for Flutter in Homebrew bin directory
    FLUTTER_PATH="/opt/homebrew/bin/flutter"
    
    if [ -f "$FLUTTER_PATH" ]; then
        echo "Flutter found at: $FLUTTER_PATH"
    else
        echo "Error: Flutter not found at $FLUTTER_PATH. Please ensure it's installed via Homebrew."
        return 1
    fi
    
    # Add Flutter to PATH in .zshrc if not already present
    if ! grep -q "export PATH=.*flutter/bin" "$HOME_PATH/.config/zsh/.zshrc"; then
        echo "export PATH=\"\$PATH:$(dirname "$FLUTTER_PATH")\"" >> "$HOME_PATH/.config/zsh/.zshrc"
        echo "Added Flutter to PATH in .zshrc"
    else
        echo "Flutter already in PATH"
    fi
    
    # Install Rosetta 2 for ARM Macs
    echo "Installing Rosetta 2..."
    sudo softwareupdate --install-rosetta --agree-to-license
    
    # Accept Xcode license
    sudo xcodebuild -license accept
    
    # Set up Android SDK (this step requires manual intervention)
    echo "Please open Android Studio and follow the setup wizard to install the Android SDK."
    echo "After installation, run: flutter config --android-sdk <path_to_android_sdk>"
    
    # Switch to Flutter master channel and upgrade
    echo "Switching to Flutter master channel and upgrading..."
    $FLUTTER_PATH channel master
    $FLUTTER_PATH upgrade
    
    # Run Flutter doctor
    echo "Running Flutter doctor..."
    $FLUTTER_PATH doctor -v
    
    echo "Flutter setup completed. Please check the output of 'flutter doctor' for any remaining issues."
}

# Function to set wallpaper
setup_wallpaper() {
	echo "Setting up wallpaper..."

	if [ -f "$WALLPAPER_PATH" ];
	then
# Copy the wallpaper to the user's Pictures folder
	cp "$WALLPAPER_PATH" "$HOME_PATH/Pictures/wallpaper.heic"
	chown "$USERNAME:staff" "$HOME_PATH/Pictures/wallpaper.heic"

# Set the wallpaper using osascript
	su - $USERNAME -c "osascript -e 'tell application \"System Events\" to tell every desktop to set picture to \"$HOME_PATH/Pictures/wallpaper.heic\"'"

	echo "Wallpaper set successfully."
	else
		echo "Error: Wallpaper file not found at $WALLPAPER_PATH"
		fi
	}

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
setup_wallpaper
setup_other_configs
echo "System configuration setup completed."
echo "IMPORTANT: To apply all changes, please either restart your terminal or run 'source $HOME_PATH/.config/zsh/.zshrc' in your current session."
