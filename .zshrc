# Profiling (optional, remove after testing)
# zmodload zsh/zprof

# PATH
typeset -U PATH path
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/.nvm/versions/node/v*/bin:$PATH"
export PATH="$HOME/.config/.local/scripts:$PATH"
export PATH="/opt/homebrew/opt/php@8.3/bin:/opt/homebrew/opt/php@8.3/sbin:$PATH"
export PATH="/opt/homebrew/opt/php@7.2/bin:/opt/homebrew/opt/php@7.2/sbin:$PATH"
export PATH="/usr/local/opt/icu4c/bin:/usr/local/opt/icu4c/sbin:$PATH"
export PATH="/usr/local/git/bin:$HOME/.local/bin:$HOME/.go/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/.yarn/bin:$HOME/roc_nightly-macos_apple_silicon-2025-03-22-c47a8e9cdac:$PATH"

# NVM
# NVM (immediate load)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Go
export GOROOT="/usr/local/go"
export GOPATH="$HOME/.go"

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Java & Android
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"

# Terminal Colors
export TERM="xterm-256color"
[ -n "$TMUX" ] && export TERM="screen-256color"

# LDFLAGS / CPPFLAGS for PHP
export LDFLAGS="-L/opt/homebrew/opt/php@8.3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/php@8.3/include"

# GVM (Go Version Manager)
gvm() {
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
  gvm "$@"
}

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
zsh-defer source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer . "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1

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
alias php8.1="valet use php@8.1"

# PHP switchers
alias 8.1='{ brew unlink php@7.2; brew unlink php@7.3; brew unlink php@7.4; brew unlink php@8.0; brew link php@8.1 --force --overwrite; } &>/dev/null && php -v'

# Node legacy flag
alias legacy="export NODE_OPTIONS=--openssl-legacy-provider"

# Dock
alias dockhide='defaults write com.apple.dock autohide -bool true && killall Dock'
alias dockshow='defaults write com.apple.dock autohide -bool false && killall Dock'
alias docktoggle='current=$(defaults read com.apple.dock autohide); if [ "$current" -eq 1 ]; then dockshow; else dockhide; fi'

# Starship prompt
eval "$(starship init zsh)"

#tmux session
alias ssn="$HOME/.config/.local/scripts/tmux-sessionizer"
alias conf="nvim $HOME/.config/"


# FZF
source <(fzf --zsh)
bindkey '^T' fzf-file-widget

# Spectrum colors
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

# Profiling (optional, remove after testing)
# zprof

