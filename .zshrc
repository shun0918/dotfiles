export PATH="$HOME/.rbenv/bin:$PATH"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# Editor
export EDITOR=nvim
export VISUAL=nvim
# export AWS_REGION=us-west-2
# export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-1-20250805-v1:0'
# export CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192

# Linux command START
alias dc='docker compose'
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
alias gemptym='git commit --allow-empty -m "空コミット"'
alias gempty='git commit --allow-empty -m'
alias gpub='git push -u origin $(git rev-parse --abbrev-ref @) | grep -v "master"'
alias gbdeldiff='git branch --merged | egrep -v '\*' | xargs git branch -d'
alias gch='git branch | grep -v "\*" | peco | xargs git checkout'
# Git END

alias ll='ls -l'
alias dce='docker compose exec'

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

if [ -f "$HOME/.zshrc_local" ]; then
    source "$HOME/.zshrc_local"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "/Users/shun/.bun/_bun" ] && source "/Users/shun/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
