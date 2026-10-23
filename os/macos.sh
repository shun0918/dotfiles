# macOS setup (sourced from install.sh)

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

# Link .config files
link .config/karabiner
link .config/aerospace

# Link claude config
link .config/claude/settings.json .claude/settings.json

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

# Install fzf-tab (not available in Homebrew)
FZF_TAB_DIR="$HOME/.zsh/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    mkdir -p "$HOME/.zsh"
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
else
    git -C "$FZF_TAB_DIR" pull --ff-only || true
fi

# Install packages
brew bundle --file="$DOTFILES_DIR/Brewfile"
[ -f "$HOME/Brewfile.local" ] && brew bundle --file="$HOME/Brewfile.local"

echo "Done! Restart your terminal or run: source ~/.zshrc"
