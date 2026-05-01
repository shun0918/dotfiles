export PATH="$HOME/.rbenv/bin:$PATH"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# LANG
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# Editor
export EDITOR=nvim
export VISUAL=nvim
export CLAUDE_CODE_EFFORT_LEVEL=max
alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'
alias ccp='pbpaste | perl -pe "s/\e\[[0-9;]*[A-Za-z]//g; s/[ \t]+$//" | pbcopy'

# Linux command START
alias dc='docker compose'
alias oxker='oxker --host unix://$HOME/.docker/run/docker.sock'
# Linux command END

# Git START
alias grsh='git reset --soft HEAD~1'
alias gb='git branch'
alias gbc='git branch --contains=HEAD --format="%(refname:short)"'
alias ga='git add'
alias gcm='git commit'
alias gcmnv='git commit --no-verify'
alias gpull='git pull'
alias gc-='git checkout -'
alias glo='git log --oneline'
alias gc='git checkout'
alias gs='git switch'
alias gst="git status"
alias gemptym='git commit --allow-empty -m "空コミット"'
alias gempty='git commit --allow-empty -m'
alias gpub='git push -u origin $(git rev-parse --abbrev-ref @) | grep -v "master"'
alias gbdeldiff='git branch --merged | egrep -v '\*' | xargs git branch -d'
alias gch='git branch | grep -v "\*" | peco | xargs git checkout'
alias lg='lazygit'
# Git END

function mdv() {
  local file
  file=$(find "${1:-.}" -name "*.md" -not -path "*/.git/*" 2>/dev/null \
    | fzf --preview 'glow --style dark {}' \
          --preview-window 'right:60%:wrap' \
          --prompt 'Markdown> ')
  [[ -n "$file" ]] && glow --pager "$file"
}

alias ll='ls -l'
alias dce='docker compose exec'
alias dexec='docker exec -it $(docker ps --format "{{.Names}}" | fzf) bash'
alias today='date "+%Y-%m-%d"'

mkcd () {
  mkdir "$1" && cd "$1"
}

function repo () {
  local dir
  dir=$(ghq list -p | peco)
  cd $dir
}

function myprs() {
  local me=$(gh api user --jq .login)
  local author_prs=$(gh pr list --author "$me" --json url --jq '.[].url')
  local assignee_prs=$(gh pr list --assignee "$me" --json url --jq '.[].url')
  echo -e "$author_prs\n$assignee_prs" | sort -u
}

awsso() {
  PROFILE=$(cat ~/.aws/config | grep profile | awk '{print $2}' | tr -d '\]' | fzf)
  export AWS_PROFILE="$PROFILE"
  aws sso login
  aws sts get-caller-identity
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY

# Completion
autoload -Uz compinit
compinit -C

if [ -f "$HOME/.zshrc_local" ]; then
    source "$HOME/.zshrc_local"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "/Users/shun/.bun/_bun" ] && source "/Users/shun/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shun/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shun/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/shun/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shun/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$HOME/.local/bin:$PATH"

# Plugins (must be after compinit; syntax-highlighting must be sourced LAST)
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# fzf-tab
[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ] && \
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'tree -C -L 1 $realpath 2>/dev/null || ls -la $realpath'

# zsh-autosuggestions (inline ghost text)
[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting (MUST be last)
[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
