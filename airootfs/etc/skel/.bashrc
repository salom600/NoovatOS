# NovatOS default .bashrc
# History
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend checkwinsize autocd cdspell

# Aliases
alias ls='exa --group-directories-first --icons'
alias ll='exa -la --group-directories-first --icons'
alias la='exa -a --group-directories-first --icons'
alias lt='exa -T --icons'
alias cat='bat --style=plain'
alias grep='ripgrep'
alias find='fd'
alias top='btop'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -pv'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias aur='yay'
alias store='bauh'

# Prompt
PS1='\[\e[34m\]\w\[\e[0m\] \[\e[32m\]❯\[\e[0m\] '

# Fastfetch on first login
if command -v fastfetch >/dev/null 2>&1 && [ -z "$FASTFETCH_SHOWN" ]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi
