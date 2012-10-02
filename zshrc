### General options ###
# Report time if command runs >2s
REPORTTIME=2
# display PID when suspending processes
setopt longlistjobs
# report status of background jobs
setopt notify
# don't kill background jobs
setopt nohup

### History ###
# Path to the history file
HISTFILE=$HOME/.zsh_history
# Size of the history and how much to actually save
HISTSIZE=5000
SAVEHIST=$HISTSIZE
# Ignore duplicate commands in the history
setopt hist_ignore_all_dups
# share history among other zsh sessions
setopt SHARE_HISTORY

### Variables ###
export BROWSER="google-chrome"
export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="vimpager"
export MANPAGER="less"
export PATH="$PATH:$HOME/bin"

### Colors for ls ###
[[ -f ~/.dircolors ]] && eval $(dircolors ~/.dircolors) || eval $(dircolors)

### keybindings (rxvt) ###
# vi mode
bindkey -v
# home/end
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
# Shift=Tab (completion)
bindkey "\e[Z" reverse-menu-complete
# insert
bindkey "\e[2~" overwrite-mode
# delete
bindkey "\e[3~" delete-char
# history search with started command
bindkey "\e[A" up-line-or-search
bindkey "\e[B" down-line-or-search
# Ctrl+R
bindkey '^R' history-incremental-search-backward
# / in command mode
bindkey -M vicmd '/' history-incremental-search-backward

### aliases ###
alias ls='ls --color --escape --classify'
alias less=$PAGER
alias zless=$PAGER
alias nano='nano --nowrap'
alias scr='screen -U -xRR'
alias s='ssh'
alias m='mosh'

### completion ###
# init completion
autoload -U compinit && compinit
# display menu if there are >5 completions
zstyle ':completion:*' menu select=5 
# use colors for file completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# use groups for completion
zstyle ':completion:*:descriptions' format \
    $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
# warn if there are no matches
zstyle ':completion:*:warnings' format \
    $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
# display all processes for killall/...
zstyle ':completion:*:processes-names' command \
    'ps c -u ${USER} -o command | uniq'
# group man pages per section
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
# match uppercase with lowercase chars
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# verbose output
zstyle ':completion:*' verbose true
# show file types
setopt listtypes

### Prompt ###
