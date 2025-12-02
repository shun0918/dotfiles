#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Create symlink with backup if needed
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$1"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Already linked: $1"
        return 0
    fi

    # Backup existing file/directory/symlink (including broken symlinks)
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest.backup"
        mv "$dest" "$dest.backup"
        echo "Backed up: $1 -> $1.backup"
    fi

    ln -s "$src" "$dest"
    echo "Linked: $1"
}

# Link dotfiles
link .direnvrc
link .gitconfig
link .gitignore_global
link .tmux.conf
link .vimrc
link .vim
link .zshenv
link .zshrc
link Brewfile

# Link karabiner config
mkdir -p "$HOME/.config"
link .config/karabiner
link .config/nvim

# Function to create .gitconfig.local interactively
create_gitconfig_local() {
    if [ -f "$HOME/.gitconfig.local" ]; then
        echo "~/.gitconfig.local already exists, skipping."
        return
    fi

    echo "Setup gitconfig..."
    read -p "Enter your git user.name: " git_name
    read -p "Enter your git user.email: " git_email

    sed -e "s/YOUR_NAME/$git_name/" -e "s/YOUR_EMAIL/$git_email/" \
        "$DOTFILES_DIR/.gitconfig.local.template" > "$HOME/.gitconfig.local"

    echo "~/.gitconfig.local created."
}

# Create local config files from templates if they don't exist
[ ! -f "$HOME/.zshrc_local" ] && cp "$DOTFILES_DIR/.zshrc_local.template" "$HOME/.zshrc_local"
create_gitconfig_local
[ ! -f "$HOME/Brewfile.local" ] && [ -f "$DOTFILES_DIR/Brewfile.local.template" ] && \
    cp "$DOTFILES_DIR/Brewfile.local.template" "$HOME/Brewfile.local"

# Install packages
brew bundle --file="$DOTFILES_DIR/Brewfile"
[ -f "$HOME/Brewfile.local" ] && brew bundle --file="$HOME/Brewfile.local"

echo "Done! Restart your terminal or run: source ~/.zshrc"
