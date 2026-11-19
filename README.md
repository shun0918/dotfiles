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

## Applying changes on an existing Mac

Most settings are symlinked, so edits take effect the next time the shell or app
loads them. Reapply links when new config files are added:

```bash
cd ~/dotfiles
./install.sh --links-only
```

This only updates config links and `~/.claude/settings.json`; it does not install
packages, update fzf-tab, or create local config files. Existing files are backed
up as `.backup`, `.backup.1`, etc., without overwriting previous backups. Missing
sources are skipped.

`~/.claude/settings.json` is a regular file, not a symlink, because Claude Code and
other tools write to it. `install.sh` merges `.config/claude/settings.json` into it.
Objects merge, arrays gain missing items, and other values come from dotfiles. If
you delete a key or an array item from dotfiles, it stays in
`~/.claude/settings.json`. Run `./install.sh --links-only` after you edit
`.config/claude/settings.json`. Changes made inside Claude Code stay in
`~/.claude/settings.json`, so copy the shared ones into
`.config/claude/settings.json` by hand.

To install missing Homebrew packages without upgrading existing ones:

```bash
brew bundle --file=~/dotfiles/Brewfile --no-upgrade
brew bundle --file=~/Brewfile.local --no-upgrade
```

Open a new terminal afterward. The regular `./install.sh` also installs packages
and may upgrade them. Packages removed from the Brewfile are not uninstalled
automatically.

## What it does

- Creates symlinks for shared config (`nvim`, `lazygit`, shell aliases, Claude `CLAUDE.md` / skills)
- macOS
  - Installs Homebrew (if not installed)
  - Creates symlinks for dotfiles (`.zshrc`, `.gitconfig`, `.tmux.conf`, etc.)
  - Merges `.config/claude/settings.json` into `~/.claude/settings.json`
  - Installs packages from `Brewfile`
  - Creates `~/.zshrc_local`, `~/.gitconfig.local`, and `~/Brewfile.local` from templates
- Linux
  - Installs `nvim`, `fzf`, `rg`, `lazygit`, `herdr`, `ghq` from GitHub Releases into `~/.local` (no Homebrew)
  - Installs `codex` with npm into `~/.local` (skipped if npm is not found)
  - Installs the gh extension `gh-stack` (skipped if gh is not found)
  - Sets `ghq.root` to `~` if not set
  - Links shell aliases to `~/.bash_aliases`

## File structure

- `install.sh` - Entry point. Links shared config and runs `os/macos.sh` or `os/linux.sh`
- `.config/shell/aliases.sh` - Aliases and functions shared by zsh and bash
- `.config/claude/settings.json` - Shared Claude Code settings, merged into `~/.claude/settings.json`
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
