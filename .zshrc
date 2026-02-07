
# =====================================================
# 1. PROFILING / DEBUG (optional)
# =====================================================
zmodload zsh/zprof


# =====================================================
# 2. CORE ENVIRONMENT
# =====================================================
typeset -U PATH path

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$HOME/.config/.local/scripts:$HOME/.local/bin:$PATH"
export PATH="$HOME/.go/bin:/usr/local/go/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/.yarn/bin:$PATH"
export PATH="/usr/local/git/bin:$PATH"
export PATH="$HOME/roc_nightly-macos_apple_silicon-2025-03-22-c47a8e9cdac:$PATH"

export EDITOR="nvim"


# =====================================================
# 3. TERMINAL / TMUX AUTO-ATTACH
# =====================================================
export TERM="xterm-256color"
[ -n "$TMUX" ] && export TERM="tmux-256color"

if command -v tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ]; then
    if [ "$TERM_PROGRAM" = "Ghostty" ] || [ -n "$GHOSTTY" ] || [[ "$TERM" == *"xterm"* ]]; then
      tmux attach-session -t main || tmux new-session -s main
      exit
    fi
  fi
fi


# =====================================================
# 4. LANGUAGE RUNTIMES / SDKs
# =====================================================

# Node (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Go
export GOROOT="/usr/local/go"
export GOPATH="$HOME/.go"

# Java / Android
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"

# PHP
export PATH="/opt/homebrew/opt/php@8.3/bin:/opt/homebrew/opt/php@8.3/sbin:$PATH"
export PATH="/opt/homebrew/opt/php@7.2/bin:/opt/homebrew/opt/php@7.2/sbin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/php@8.3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/php@8.3/include"

# Herd
export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
export PATH="$HOME/Library/Application Support/Herd/bin:$PATH"


# =====================================================
# 5. PACKAGE MANAGERS
# =====================================================

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# GVM (lazy)
gvm() {
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
  gvm "$@"
}


# =====================================================
# 6. OH MY ZSH + PLUGINS
# =====================================================
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled

plugins=(
  git
  zsh-autosuggestions
  fast-syntax-highlighting
  zsh-defer
  zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh

# Enable vi-mode (IMPORTANT)
zvm_init


# =====================================================
# 7. COMPLETION SYSTEM
# =====================================================
ZSH_DISABLE_COMPFIX=true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

autoload -Uz compinit
compinit -u

# Carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
source <(carapace _carapace)


# =====================================================
# 8. KEYBINDINGS & VI-MODE TUNING
# =====================================================

# zsh-vi-mode behavior
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_KEYTIMEOUT=1
ZVM_CURSOR_STYLE_ENABLED=true

# Autosuggestions
zsh-defer source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey -r '^L'
bindkey '^L' autosuggest-accept
zle -N autosuggest-accept
bindkey -M viins '^L' autosuggest-accept
bindkey -M vicmd '^L' autosuggest-accept

# Fix TAB in insert mode
bindkey -M viins '^I' expand-or-complete


# =====================================================
# 9. PROMPT & UI
# =====================================================
eval "$(starship init zsh)"

# FZF
source <(fzf --zsh)
bindkey '^T' fzf-file-widget

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


# =====================================================
# 10. HISTORY / SEARCH (ATUIN)
# =====================================================
eval "$(atuin init zsh)"

bindkey -M viins '^r' atuin-search
bindkey -M vicmd '/' atuin-search


# =====================================================
# 11. BAT, EZA, THEFUCK
# =====================================================

export BAT_THEME=tokyonight

alias ls="eza --icons=always --oneline"

eval $(thefuck --alias)
eval $(thefuck --alias fk)


# =====================================================
# 12. ALIASES
# =====================================================
alias gst="git status | lolcat"
alias pull="git pull | lolcat"
alias gcm="git commit -am "
alias gaa="git add ."

alias godir="cd .go/src/gowork"
alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc"

alias nconfig="cd $HOME/.config/nvim && nvim ."
alias zconfig="nvim ~/.zshrc"
alias copyz="cp -r ~/.zshrc ~/.config/zconfig"
alias gconfig="cd $HOME/.config/ghostty/config && nvim ."
alias conf="cd $HOME/.config && nvim ."
alias ssn="$HOME/.config/.local/scripts/tmux-sessionizer"

alias cldir="find . -name '*.DS_Store' -type f -delete"
alias cover="zed $HOME/Documents/resume/cover.txt"

alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias pg_stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

alias php8.1="valet use php@8.1"
alias 8.1='{ brew unlink php@7.2; brew unlink php@7.3; brew unlink php@7.4; brew unlink php@8.0; brew link php@8.1 --force --overwrite; } &>/dev/null && php -v'

alias legacy="export NODE_OPTIONS=--openssl-legacy-provider"

alias dockhide='defaults write com.apple.dock autohide -bool true && killall Dock'
alias dockshow='defaults write com.apple.dock autohide -bool false && killall Dock'
alias docktoggle='current=$(defaults read com.apple.dock autohide); [[ $current -eq 1 ]] && dockshow || dockhide'


# =====================================================
# 12. VISUAL UTILITIES (SPECTRUM)
# =====================================================
typeset -AHg FX FG BG
for color in {000..255}; do
  FG[$color]="%{\e[38;5;${color}m%}"
  BG[$color]="%{\e[48;5;${color}m%}"
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


# =====================================================
# 13. MISC / EXTERNAL INJECTIONS
# =====================================================
source ~/.safe-chain/scripts/init-posix.sh


# =====================================================
# 14. PROFILING OUTPUT (optional)
# =====================================================
zprof
