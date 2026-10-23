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
#   asset: release asset name. "{version}" is replaced with the tag without "v"
install_release() {
    local name=$1 repo=$2 asset=$3 tag tmp

    if [ -x "$BIN_DIR/$name" ]; then
        echo "Already installed: $name"
        return 0
    fi

    tag=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")
    tag=${tag##*/}
    tmp=$(mktemp -d)
    curl -fsSL "https://github.com/$repo/releases/download/$tag/${asset//\{version\}/${tag#v}}" | tar -xz -C "$tmp"
    install -m 755 "$(find "$tmp" -type f -name "$name" | head -n 1)" "$BIN_DIR/$name"
    rm -rf "$tmp"
    echo "Installed: $name $tag"
}

# Each project uses a different arch notation in asset names (arm64 / aarch64 / amd64)
install_release fzf     junegunn/fzf          "fzf-{version}-linux_${ARCH/x86_64/amd64}.tar.gz"
install_release rg      BurntSushi/ripgrep    "ripgrep-{version}-${ARCH/arm64/aarch64}-unknown-linux-musl.tar.gz"
install_release lazygit jesseduffield/lazygit "lazygit_{version}_linux_${ARCH}.tar.gz"

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

echo "Done! Restart your shell or run: source ~/.bashrc"
