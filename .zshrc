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
