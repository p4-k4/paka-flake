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

# Function to set up other configurations (placeholder for future additions)
setup_other_configs() {
    echo "Setting up other configurations..."
    # Add other configuration setup steps here
    # For example:
    # setup_vim
    # setup_tmux
    # etc.
}

# Main execution
echo "Starting system configuration setup..."

setup_zsh
setup_other_configs

echo "System configuration setup completed."
