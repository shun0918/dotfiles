# Linux setup (sourced from install.sh)
# Homebrew is not used. On Coder only $HOME is persistent, so tools go to ~/.local

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

case "$(uname -m)" in
    x86_64)        ARCH=x86_64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

# Ubuntu's default ~/.bashrc sources ~/.bash_aliases
link .config/shell/aliases.sh .bash_aliases

# Install a binary from the latest GitHub release (skipped if already installed)
# Usage: install_release <name> <owner/repo> <asset>
#   asset: release asset name (.tar.gz or .zip). "{version}" is replaced with the tag without "v"
install_release() {
    local name=$1 repo=$2 asset=$3 tag tmp

    if [ -x "$BIN_DIR/$name" ]; then
        echo "Already installed: $name"
        return 0
    fi

    tag=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")
    tag=${tag##*/}
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/asset" "https://github.com/$repo/releases/download/$tag/${asset//\{version\}/${tag#v}}"
    case "$asset" in
        *.zip) unzip -q "$tmp/asset" -d "$tmp" ;;
        *)     tar -xzf "$tmp/asset" -C "$tmp" ;;
    esac
    install -m 755 "$(find "$tmp" -type f -name "$name" | head -n 1)" "$BIN_DIR/$name"
    rm -rf "$tmp"
    echo "Installed: $name $tag"
}

# Each project uses a different arch notation in asset names (arm64 / aarch64 / amd64)
install_release fzf     junegunn/fzf          "fzf-{version}-linux_${ARCH/x86_64/amd64}.tar.gz"
install_release rg      BurntSushi/ripgrep    "ripgrep-{version}-${ARCH/arm64/aarch64}-unknown-linux-musl.tar.gz"
install_release lazygit jesseduffield/lazygit "lazygit_{version}_linux_${ARCH}.tar.gz"
install_release ghq     x-motemen/ghq         "ghq_linux_${ARCH/x86_64/amd64}.zip"

# Use $HOME as ghq root so existing clones show up too (`ghq get` goes to ~/github.com/...)
git config --global --get ghq.root > /dev/null || git config --global ghq.root '~'

# Install Neovim (the tarball has bin/, lib/ and share/)
NVIM_DIR="$HOME/.local/opt/nvim"
if [ -x "$NVIM_DIR/bin/nvim" ]; then
    echo "Already installed: nvim"
else
    mkdir -p "$NVIM_DIR"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$ARCH.tar.gz" \
        | tar -xz -C "$NVIM_DIR" --strip-components=1
    echo "Installed: nvim"
fi
ln -sf "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"

# Install herdr (the asset is a single binary)
# The official installer and `herdr update` download from herdr.dev, which Coder cannot reach
if [ -x "$BIN_DIR/herdr" ]; then
    echo "Already installed: herdr"
else
    curl -fsSL -o "$BIN_DIR/herdr" "https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-${ARCH/arm64/aarch64}"
    chmod +x "$BIN_DIR/herdr"
    echo "Installed: herdr"
fi

# Install Codex CLI with the environment's npm (Node is not installed here)
if [ -x "$BIN_DIR/codex" ]; then
    echo "Already installed: codex"
elif command -v npm > /dev/null; then
    npm install -g --prefix "$HOME/.local" @openai/codex
    echo "Installed: codex"
else
    echo "Skipped: codex (npm not found)"
fi

echo "Done! Restart your shell or run: source ~/.bashrc"
