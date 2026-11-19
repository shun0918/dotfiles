#!/bin/bash
set -e

LINKS_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --links-only) LINKS_ONLY=true ;;
        -h|--help)
            echo "Usage: $0 [--links-only]"
            echo "  --links-only  Update config symlinks and Claude settings without installing or updating packages."
            exit 0
            ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create symlink with backup if needed
# Usage: link <src> [dest]
#   src:  path relative to $DOTFILES_DIR
#   dest: path relative to $HOME (defaults to src)
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/${2:-$1}"

    if [ ! -e "$src" ]; then
        echo "Skipping missing source: $1"
        return 0
    fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Already linked: $1"
        return 0
    fi

    # Backup existing file/directory/symlink (including broken symlinks)
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup="$dest.backup" suffix=0
        while [ -e "$backup" ] || [ -L "$backup" ]; do
            suffix=$((suffix + 1))
            backup="$dest.backup.$suffix"
        done
        mv "$dest" "$backup"
        echo "Backed up: $dest -> $backup"
    fi

    ln -s "$src" "$dest"
    echo "Linked: $1"
}

merge_json() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/${2:-$1}"
    local tmp

    if [ ! -e "$src" ]; then
        echo "Skipping missing source: $1"
        return 0
    fi

    if [ ! -s "$dest" ]; then
        rm -f "$dest"
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo "Copied: $1"
        return 0
    fi

    if ! command -v jq > /dev/null; then
        echo "Skipped: $1 (jq not found)" >&2
        return 0
    fi

    # With -e, an empty src fails instead of writing null over dest
    tmp=$(mktemp "$dest.XXXXXX")
    if ! jq -e --slurpfile src "$src" '
        def merge($s):
            if type == "object" and ($s | type) == "object" then
                reduce ($s | keys_unsorted[]) as $k (.; .[$k] |= merge($s[$k]))
            elif type == "array" and ($s | type) == "array" then
                . + ($s - .)
            else
                $s
            end;
        merge($src[0])
    ' "$dest" > "$tmp"; then
        rm -f "$tmp"
        echo "Failed to merge: $dest" >&2
        return 1
    fi
    mv "$tmp" "$dest"
    echo "Merged: $1"
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

# OS specific setup
case "$(uname -s)" in
    Darwin) source "$DOTFILES_DIR/os/macos.sh" ;;
    Linux)  source "$DOTFILES_DIR/os/linux.sh" ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
