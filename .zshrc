
# =====================================================
# 1. PROFILING / DEBUG (optional)
# =====================================================
#zmodload zsh/zprof


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

# Cache the init scripts that tools print, so startup doesn't spawn each tool.
# A cache rebuilds when the tool's resolved path changes (brew upgrade), the
# binary is newer than the cache, or the cache is a day old (carapace picks up
# newly installed commands). Clear with: rm -rf ~/.cache/zsh-init
_zinit_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init"
cached_init() {
  local name=$1; shift
  local bin=${commands[$1]} file="$_zinit_cache/$name.zsh" stamp
  local -a stale
  [[ -n $bin ]] || return 0
  [[ -s $file ]] && read -r stamp < $file
  stale=( ${~file}(Nmh+23) )
  if [[ $stamp != "# ${bin:A} $*" || $bin -nt $file || -n $stale ]]; then
    mkdir -p $_zinit_cache
    { print -r -- "# ${bin:A} $*"; "$@" } >| $file
  fi
  source $file
}


# =====================================================
# 3. TERMINAL / TMUX AUTO-ATTACH
# =====================================================
export TERM="xterm-256color"
[ -n "$TMUX" ] && export TERM="tmux-256color"

if command -v tmux >/dev/null 2>&1; then
  # NO_AUTO_TMUX=1 opts out of auto-attach (e.g. to run herdr in a bare shell)
  if [ -z "$TMUX" ] && [ -z "$NO_AUTO_TMUX" ] && [ -t 0 ] && [ -t 1 ]; then
    if [ "$TERM_PROGRAM" = "Ghostty" ] || [ -n "$GHOSTTY" ] || [[ "$TERM" == *"xterm"* ]]; then
      tmux attach-session -t main || tmux new-session -s main
      exit
    fi
  fi
fi


# =====================================================
# 4. LANGUAGE RUNTIMES / SDKs
# =====================================================

# Node (NVM) - lazy loaded for faster startup
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

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
  #zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh

# Enable vi-mode (IMPORTANT)



# =====================================================
# 7. COMPLETION SYSTEM
# =====================================================
ZSH_DISABLE_COMPFIX=true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

# compinit is already called by oh-my-zsh.sh, skip to avoid duplicate
# autoload -Uz compinit && compinit -u

# Carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
cached_init carapace carapace _carapace


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
cached_init starship starship init zsh

# Narrow panes (loom and tmux splits) get the compact prompt: no user name,
# no language versions, a truncated branch. Starship re-reads STARSHIP_CONFIG
# on every redraw, so this runs before each prompt and on every resize.
_starship_width() {
  if (( COLUMNS < 100 )); then
    export STARSHIP_CONFIG="$HOME/.config/starship-compact.toml"
  else
    unset STARSHIP_CONFIG
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_width
# The width and config the prompt on screen was drawn with.
_prompt_drawn() { _prompt_cols=$COLUMNS; _prompt_cfg=${STARSHIP_CONFIG-} }
add-zsh-hook precmd _prompt_drawn
# On resize, redraw the prompt already on screen with the right config.
# When a pane gets narrower than that prompt, the terminal re-wraps it onto
# more rows, but zsh does not know and would redraw it lower. So measure the
# old prompt's first line, move up over the rows the wrap added, then redraw
# with the builtin .reset-prompt so no plugin's wrapped version runs.
TRAPWINCH() {
  _starship_width
  zle || return 0
  local out line w extra=0
  if (( COLUMNS < ${_prompt_cols:-0} )); then
    out=$(
      if [[ -n $_prompt_cfg ]]; then export STARSHIP_CONFIG=$_prompt_cfg; else unset STARSHIP_CONFIG; fi
      starship prompt --terminal-width=$_prompt_cols
    )
    for line in "${(@f)out}"; do [[ -n $line ]] && break; done
    line=${(S)line//\%\{*\%\}/}
    w=${(m)#line}
    (( w > 0 )) && extra=$(( (w - 1) / COLUMNS ))
    (( extra > 0 )) && print -n -- $'\e['"${extra}A"
  fi
  zle .reset-prompt
  zle -R
  _prompt_drawn
}

# FZF
cached_init fzf fzf --zsh
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
cached_init atuin atuin init zsh

bindkey -M viins '^r' atuin-search
bindkey -M vicmd '/' atuin-search


# =====================================================
# 11. BAT, EZA
# =====================================================

export BAT_THEME=tokyonight

alias ls="eza --icons=always --oneline"

# =====================================================
# 12. ALIASES
# =====================================================
# `command claude` runs the bare CLI.
# --allow-dangerously-skip-permissions ARMS bypass mode in the Shift+Tab cycle
# without activating it: cycle into "bypass permissions" mid-investigation,
# cycle back out when done. Remove the flag to hide the mode again.
# 2026-10-12: inside tmux under Ghostty, tell Claude Code its terminal is
# Ghostty. It sends Ghostty's progress bar (OSC 9;4) only when TERM_PROGRAM
# is ghostty >= 1.2.0 (2.1.296), and wraps it for tmux on its own; needs
# `allow-passthrough` in tmux.conf. Outside tmux this is plain `command claude`.
# Pictures in tmux were dropped 2026-10-12 with glass 0.9.0: a picture
# scrolled back up left an empty gap.
unalias claude 2>/dev/null
claude() {
  local outer
  [[ -n $TMUX ]] && outer=$(tmux display -p '#{client_termtype}' 2>/dev/null)
  if [[ $outer == ghostty\ * ]]; then
    TERM_PROGRAM=ghostty TERM_PROGRAM_VERSION=${outer#ghostty } command claude --allow-dangerously-skip-permissions "$@"
  else
    command claude --allow-dangerously-skip-permissions "$@"
  fi
}

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
# Launch herdr (agent multiplexer) in its own tmux-free Ghostty window.
# Output is silenced and the process is backgrounded+disowned (&!) so Ghostty's
# logs don't leak into the launching pane and your prompt returns immediately.
alias herd="/Applications/Ghostty.app/Contents/MacOS/ghostty -e herdr >/dev/null 2>&1 &!"

snipcopy() {
  local src="$HOME/.config/nvim/snippets/snippets/typescript.json"
  local dst="$HOME/Documents/codes/packages/effect-snippets/snippets/effect.json"
  local repo="$HOME/Documents/codes/packages/effect-snippets"

  cp "$src" "$dst" || { echo "snipcopy: copy failed" >&2; return 1; }

  (
    cd "$repo" || return 1
    if [ -z "$(git status --porcelain)" ]; then
      echo "snipcopy: nothing changed"
      return 0
    fi
    git add -A && \
    git commit -m "sync snippets from nvim ($(date +%Y-%m-%d))" && \
    git push
  )
}

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
#zprof


# Herd injected PHP binary.
export PATH="/Users/rashed/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/rashed/Library/Application Support/Herd/config/php/84/"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/rashed/.lmstudio/bin"
# End of LM Studio CLI section

cached_init tv tv init zsh

# kp [port] — kill whatever listens on a port (default 3000). Handy in tmux.
kp() {
  local port="${1:-3000}"
  local -a pids
  pids=(${(f)"$(lsof -ti tcp:"$port")"})
  if [ ${#pids} -gt 0 ]; then
    kill -9 "${pids[@]}" && echo "✓ port $port freed"
  else
    echo "port $port already free"
  fi
}

# hdDev [port] [extra next args...] — run the frontend workspace on a chosen port.
# One codebase, many worktrees: everything wants 3000, so pick your own.
#   hdDev                  → port 3000
#   hdDev 3001             → port 3001
#   hdDev 3002 -H 0.0.0.0  → extra args pass straight through to next
# Override the workspace with: HD_DEV_FILTER=admin hdDev 3005
hdDev() {
  local port="${1:-3000}"
  if [[ "$port" != <-> ]]; then
    echo "hdDev: port must be a number (got '$port')" >&2
    return 1
  fi
  (( $# )) && shift
  pnpm --filter "${HD_DEV_FILTER:-frontend}" exec next dev --turbo --port "$port" "$@"
}

. "$HOME/.atuin/bin/env"
