# Aliases and functions shared by zsh (macOS) and bash (Linux)

# Editor
export EDITOR=nvim
export VISUAL=nvim
export CLAUDE_CODE_EFFORT_LEVEL=max
alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'

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
