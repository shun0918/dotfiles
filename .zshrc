export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# Linux command START
alias dc='docker-compose'
# Linux command END

# Git START
alias grsh='git reset --soft HEAD~1'
alias gb='git branch'
alias ga='git add'
alias gcm='git commit'
alias gpull='git pull'
alias gc-='git checkout -'
alias glon='git log --one-line'
alias gc='git checkout'
alias gemptym='git commit --allow-empty -m "空コミット"'
alias gempty='git commit --allow-empty -m'
alias gpub='git push -u origin $(git rev-parse --abbrev-ref @) | grep -v "master"'
alias gbdeldiff='git branch --merged | egrep -v '\*' | xargs git branch -d'
# Git END

alias ll='ls -l'
alias dce='docker-compose exec'

# tebiki-skp START
alias dceb='docker-compose exec backend bash'
# tebiki-skp END

export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"


# ctrl-]でリポジトリを切り替えられるようにする
# 2023/5/14時点ではbindkeyにwarpが対応していないので注意が必要
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src
