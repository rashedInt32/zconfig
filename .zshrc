# Profiling (optional, remove after testing)
# zmodload zsh/zprof

# PATH
typeset -U PATH path
export PATH="$HOME/.nvm/versions/node/v*/bin:/opt/homebrew/bin:/opt/homebrew/opt/php@8.3/bin:/opt/homebrew/opt/php@8.3/sbin:/opt/homebrew/opt/php@7.2/bin:/opt/homebrew/opt/php@7.2/sbin:/usr/local/opt/icu4c/bin:/usr/local/opt/icu4c/sbin:/usr/local/git/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$HOME/.go/bin:/usr/local/m-cli:$HOME/.yarn/bin:$HOME/.cargo/bin:$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/roc_nightly-macos_apple_silicon-2025-03-22-c47a8e9cdac"

# Lazy-load nvm
export NVM_DIR="$HOME/.nvm"
nvm() {
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    nvm "$@"
}
node() { [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"; node "$@"; }
npm() { [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"; npm "$@"; }
npx() { [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"; npx "$@"; }

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/.go

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled
plugins=(git zsh-autosuggestions zsh-vi-mode zsh-defer)
source $ZSH/oh-my-zsh.sh

# Completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
ZSH_DISABLE_COMPFIX=true
autoload -Uz compinit
compinit -u

# Lazy-load plugins with zsh-defer
zsh-defer source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer . /Users/rashed/.opam/opam-init/init.zsh > /dev/null 2> /dev/null

# Aliases
alias godir="cd .go/src/gowork"
alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc"
alias mvim="/Applications/MacVim.app/Contents/MacOS/Vim"
alias vim="open -a MacVim.app $1"
alias gst="git status | lolcat"
alias pull="git pull | lolcat"
alias gcm="git commit -am "
alias gaa="git add ."
alias zconfig="nvim ~/.zshrc"
alias gconfig="nvim $HOME/.config/ghostty/config"
alias cldir="find . -name '*.DS_Store' -type f -delete"
alias cover="code $HOME/Documents/resume/cover.txt"
alias nconfig="nvim $HOME/.config/nvim"
alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias pg_stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias php7="valet use php@7.4"
alias php8="valet use php@8.0"
alias php8.1="valet use php@8.1"
alias 7.2='{ brew unlink php@7.3; brew unlink php@7.4; brew unlink php@8.0; brew unlink php@8.1; brew link php@7.2 --force --overwrite; } &> /dev/null && php -v'
alias 7.3='{ brew unlink php@7.2; brew unlink php@7.4; brew unlink php@8.0; brew unlink php@8.1; brew link php@7.3 --force --overwrite; } &> /dev/null && php -v'
alias 7.4='{ brew unlink php@7.2; brew unlink php@7.3; brew unlink php@8.0; brew unlink php@8.1; brew link php@7.4 --force --overwrite; } &> /dev/null && php -v'
alias 8.0='{ brew unlink php@7.2; brew unlink php@7.3; brew unlink php@7.4; brew unlink php@8.1; brew link php@8.0 --force --overwrite; } &> /dev/null && php -v'
alias 8.1='{ brew unlink php@7.2; brew unlink php@7.3; brew unlink php@7.4; brew unlink php@8.0; brew link php@8.1 --force --overwrite; } &> /dev/null && php -v'
alias legacy="export NODE_OPTIONS=--openssl-legacy-provider"
alias dockhide='defaults write com.apple.dock autohide -bool true && killall Dock'
alias dockshow='defaults write com.apple.dock autohide -bool false && killall Dock'
alias docktoggle='current=$(defaults read com.apple.dock autohide); if [ "$current" -eq 1 ]; then dockshow; else dockhide; fi'

# Starship
eval "$(starship init zsh)"

# FZF
source <(fzf --zsh)
bindkey '^T' fzf-file-widget

# Spectrum (color functions)
typeset -AHg FX FG BG
for color in {000..255}; do
    FG[$color]="%{[38;5;${color}m%}"
    BG[$color]="%{[48;5;${color}m%}"
done
ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}
spectrum_ls() {
  for code in {000..255}; do
    print -P -- "$code: %{$FG[$code]%}$ZSH_SPECTRUM_TEXT%{$reset_color%}"
  done
}
spectrum_bls() {
  for code in {000..255}; do
    print -P -- "$code: %{$BG[$code]%}$ZSH_SPECTRUM_TEXT%{$reset_color%}"
  done
}

# Environment variables
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export LDFLAGS="-L/opt/homebrew/opt/php@8.3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/php@8.3/include"

# GVM
gvm() {
    [[ -s "/Users/rashed/.gvm/scripts/gvm" ]] && source "/Users/rashed/.gvm/scripts/gvm"
    gvm "$@"
}

# Profiling (optional, remove after testing)
# zprof
