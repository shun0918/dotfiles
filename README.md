# dotfiles

Personal dotfiles for macOS

## Installation

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What it does

- Installs Homebrew (if not installed)
- Creates symlinks for dotfiles (`.zshrc`, `.gitconfig`, `.tmux.conf`, etc.)
- Installs packages from `Brewfile`
- Creates `~/.zshrc_local` and `~/Brewfile.local` from templates

## File structure

- `Brewfile` - Common packages (tracked in git)
- `Brewfile.local` - Machine-specific packages (ignored in git)
- `.zshrc` - Common shell configuration (tracked in git)
- `.zshrc_local` - Machine-specific shell configuration (ignored in git)
- `*.template` - Templates for local files

## Customization

After installation, customize these files:

- `~/.zshrc_local` - Add machine-specific aliases and environment variables
- `~/Brewfile.local` - Add machine-specific Homebrew packages

Then run:
```bash
brew bundle --file=~/Brewfile.local
source ~/.zshrc
```
