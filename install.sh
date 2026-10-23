#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create symlink with backup if needed
# Usage: link <src> [dest]
#   src:  path relative to $DOTFILES_DIR
#   dest: path relative to $HOME (defaults to src)
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/${2:-$1}"

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

# Link .config files (shared by all OS)
mkdir -p "$HOME/.config"
link .config/nvim
link .config/lazygit
link .config/shell

# Link claude config (shared by all OS)
mkdir -p "$HOME/.claude"
link .config/claude/CLAUDE.md .claude/CLAUDE.md
link .config/claude/skills .claude/skills
link .config/claude/agents .claude/agents

# OS specific setup
case "$(uname -s)" in
    Darwin) source "$DOTFILES_DIR/os/macos.sh" ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
