# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# tebiki-web START
alias ll='ls -l'
alias dce='docker-compose exec'
alias dcers='docker-compose exec web rspec'
alias dceru='docker-compose exec web rubocop'
alias dcel='docker-compose exec web yarn run lint'
alias dcees='docker-compose exec web yarn lint'
alias dceje='docker-compose exec web yarn test'
alias dcelog='docker-compose logs --tail=100 -f web'
# tebiki-web END

# tebiki-skp START
alias dceb='docker-compose exec backend bash'
# tebiki-skp END

# PREZTO START
source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
# PREZTO END

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
