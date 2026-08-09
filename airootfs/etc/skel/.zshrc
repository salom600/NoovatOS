# NovatOS default .zshrc (live user + installed user)
# Auto-loads: bash-completion equivalent, starship-like prompt (built-in), aliases

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY

# Auto-completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Vi mode (optional, off by default for Windows migrants)
bindkey -e

# Aliases (Windows-migrant friendly)
alias ls='exa --group-directories-first --icons'
alias ll='exa -la --group-directories-first --icons'
alias la='exa -a --group-directories-first --icons'
alias lt='exa -T --icons'
alias cat='bat --style=plain'
alias grep='ripgrep'
alias find='fd'
alias top='btop'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias mkdir='mkdir -pv'
alias ports='sudo netstat -tulpn'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias aur='yay'
alias store='bauh'

# Prompt (custom, lightweight — no oh-my-zsh needed)
PROMPT='%F{#4cc2ff}%~%f %F{#a6e3a1}❯%f '
RPROMPT='%F{#7f849c}%? | %T%f'

# Tools
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Auto-cd by typing directory name
setopt AUTO_CD

# Spell correction
setopt CORRECT
