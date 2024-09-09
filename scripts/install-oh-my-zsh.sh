#!/bin/bash

set -e

USERNAME="$1"
HOME_PATH="$2"

# Check if oh-my-zsh is already installed
if [ ! -d "${HOME_PATH}/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh for ${USERNAME}..."
  sudo -u "${USERNAME}" HOME="${HOME_PATH}" sh -c 'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended'
else
  echo "oh-my-zsh is already installed for ${USERNAME}"
fi
