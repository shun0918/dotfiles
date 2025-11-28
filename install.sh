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
        return 0
    fi

    [ -e "$dest" ] && mv "$dest" "$dest.backup"
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

# Create .zshrc_local from template if not exists
[ ! -f "$HOME/.zshrc_local" ] && cp "$DOTFILES_DIR/.zshrc_local.template" "$HOME/.zshrc_local"

# Create .gitconfig.local from template if not exists
[ ! -f "$HOME/.gitconfig.local" ] && cp "$DOTFILES_DIR/.gitconfig.local.template" "$HOME/.gitconfig.local"

# Create Brewfile.local from template if not exists
[ ! -f "$HOME/Brewfile.local" ] && [ -f "$DOTFILES_DIR/Brewfile.local.template" ] && \
    cp "$DOTFILES_DIR/Brewfile.local.template" "$HOME/Brewfile.local"

# Install packages
brew bundle --file="$DOTFILES_DIR/Brewfile"
[ -f "$HOME/Brewfile.local" ] && brew bundle --file="$HOME/Brewfile.local"

echo "Done! Restart your terminal or run: source ~/.zshrc"
