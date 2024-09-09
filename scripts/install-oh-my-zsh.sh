#!/bin/bash
set -e
USERNAME="$1"
HOME_PATH="$2"

# Function to install a custom plugin
install_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="${HOME_PATH}/.oh-my-zsh/custom/plugins/${plugin_name}"
    
    if [ ! -d "$plugin_dir" ]; then
        echo "Installing ${plugin_name}..."
        sudo -u "${USERNAME}" git clone "$plugin_url" "$plugin_dir"
    else
        echo "${plugin_name} is already installed"
    fi
}

# Check if oh-my-zsh is already installed
if [ ! -d "${HOME_PATH}/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh for ${USERNAME}..."
    sudo -u "${USERNAME}" HOME="${HOME_PATH}" sh -c 'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended'
else
    echo "oh-my-zsh is already installed for ${USERNAME}"
fi

# Install zsh-autosuggestions
install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"

# Install zsh-syntax-highlighting
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# Add plugins to .zshrc or create it if it doesn't exist
ZSHRC="${HOME_PATH}/.zshrc"
if [ ! -f "$ZSHRC" ]; then
    echo "Creating .zshrc file..."
    echo 'export ZSH="$HOME/.oh-my-zsh"' > "$ZSHRC"
    echo 'ZSH_THEME="robbyrussell"' >> "$ZSHRC"
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
    echo 'source $ZSH/oh-my-zsh.sh' >> "$ZSHRC"
    chown "${USERNAME}:staff" "$ZSHRC"
else
    if ! grep -q "zsh-autosuggestions" "$ZSHRC" || ! grep -q "zsh-syntax-highlighting" "$ZSHRC"; then
        echo "Adding plugins to .zshrc..."
        sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
    else
        echo "Plugins are already in .zshrc"
    fi
fi

echo "Oh My Zsh setup with additional plugins completed."
