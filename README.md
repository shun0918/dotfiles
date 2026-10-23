# dotfiles

Personal dotfiles for macOS and Linux (Coder)

## Installation

### macOS

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Linux (Coder)

Run in the workspace. It clones the repo to `~/.config/coderv2/dotfiles` and runs `install.sh`.

```bash
coder dotfiles -y https://github.com/your-username/dotfiles.git
```

## What it does

- Creates symlinks for shared config (`nvim`, `lazygit`, shell aliases, Claude `CLAUDE.md` / skills / agents)
- macOS
  - Installs Homebrew (if not installed)
  - Creates symlinks for dotfiles (`.zshrc`, `.gitconfig`, `.tmux.conf`, etc.)
  - Installs packages from `Brewfile`
  - Creates `~/.zshrc_local`, `~/.gitconfig.local`, and `~/Brewfile.local` from templates
- Linux
  - Installs `nvim`, `fzf`, `rg`, `lazygit`, `herdr` from GitHub Releases into `~/.local` (no Homebrew)
  - Links shell aliases to `~/.bash_aliases`

## File structure

- `install.sh` - Entry point. Links shared config and runs `os/macos.sh` or `os/linux.sh`
- `.config/shell/aliases.sh` - Aliases and functions shared by zsh and bash
- `Brewfile` - Common packages (tracked in git)
- `Brewfile.local` - Machine-specific packages (ignored in git)
- `.zshrc` - Common shell configuration (tracked in git)
- `.zshrc_local` - Machine-specific shell configuration (ignored in git)
- `.gitconfig` - Common git configuration (tracked in git)
- `.gitconfig.local` - User-specific git configuration (ignored in git)
- `*.template` - Templates for local files

## Customization

After installation, customize these files:

- `~/.gitconfig.local` - Set your git user name and email
- `~/.zshrc_local` - Add machine-specific aliases and environment variables
- `~/Brewfile.local` - Add machine-specific Homebrew packages

Then run:
```bash
brew bundle --file=~/Brewfile.local
source ~/.zshrc
```
