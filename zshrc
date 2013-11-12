#!/bin/bash
### General options ###
# Report time if command runs >2s
REPORTTIME=2
# display PID when suspending processes
setopt longlistjobs
# report status of background jobs
setopt notify
# don't kill background jobs
setopt nohup
# pkgfile command_not_found handler
if [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
fi
# easy color names in this config
autoload -U colors && colors

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
# Ignore commands starting with a space
setopt hist_ignore_space

### Variables ###
if [[ "$OS" == Windows_NT ]]; then
    export PATH="/usr/local/bin:/usr/bin:$PATH"
    export SHELL="/usr/bin/zsh"
    export TERM="cygwin"
    alias open='cygstart'
else
    export BROWSER="dwb"
    export EDITOR="vim"
    export VISUAL="$EDITOR"
    export PATH="$PATH:$HOME/bin"
    export VIEW_PDF="zathura" # for latex-makefile
    export PAGER="less"
fi

### Colors for ls ###
[[ -f ~/.dircolors ]] && eval $(dircolors ~/.dircolors) || eval $(dircolors)

### Colors and syntax highlighting for less ###
export LESS="-R -M +g"
export LESS_TERMCAP_me=$(printf '\e[0m')
export LESS_TERMCAP_se=$(printf '\e[0m')
export LESS_TERMCAP_ue=$(printf '\e[0m')
export LESS_TERMCAP_mb=$(printf '\e[1;32m')
export LESS_TERMCAP_md=$(printf '\e[1;34m')
export LESS_TERMCAP_us=$(printf '\e[1;32m')
export LESS_TERMCAP_so=$(printf '\e[1;44;1m')
export LESSCOLORIZER=code2color

### general colors ###
if which cope_path &>/dev/null; then
    PATH="$(cope_path):$PATH"
fi

### settings
export ACK_COLOR_MATCH="bold red"
export SUDO_PROMPT='[sudo] password for %u@%h (-> %U): '
export GIT_PAGER='less +g'

### keybindings ###
# vi mode
bindkey -v
# home/end (urxvt)
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
# home/end (xterm)
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
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

### aliases / functions ###
# default settings
alias ls='ls --color --escape --classify'
alias l='ls --color --escape --classify -lah'
alias grep='grep --color=auto'
alias nano='nano --nowrap'
# shorthands
alias scr='screen -U -xRR'
alias s='ssh'
alias m='mosh'
alias hc='herbstclient'
alias yu='yaourt -Suya; sudo abs; sudo pkgfile -u; gpg --refresh-keys; gpg --update-trustdb; sudo pacdiffviewer'
alias yi='yaourt -S'
alias yq='yaourt -Si'
alias yl='yaourt -Ql'
alias tx='tmux -2 attach -d'
# pseudo-functions
alias clock='watch -t -n 0.5 "date +%T | toilet -f bigascii12"'
alias pymath='bpython -i <(echo "from math import *")'
alias newx='xinit /usr/bin/urxvt -- :1'
alias nmapa='nmap -T Aggressive -P0 -sT -p 1-65535'
# functions
xoj() { for f in "$@"; do xournal "$f" &>/dev/null & disown; done }
pdf() { "$VIEW_PDF" "$@" &>/dev/null & disown }
qr() { qrencode "$1" -o- -t ANSIUTF8; }
genpwd() { tr -dc A-Za-z0-9 < /dev/urandom | head -c 8; echo }
igitt() { git clone "ssh://git@the-compiler.org/$1" ;}
bashhelp() { bash -c "help -m '$1'" | $PAGER ;}
# ignore dangerous commands from history and make them safer and more verbose
alias rm=' rm -I -v'
alias chmod=' chmod -c'
alias chown=' chown -c'
alias shred=' shred -u -z -v'
alias cp='cp -i -v'
alias mv='mv -i -v'

### completion ###
# init completion
autoload -U compinit && compinit
# display menu if there are >5 completions
zstyle ':completion:*' menu select=5 
# use colors for file completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# use groups for completion
zstyle ':completion:*:descriptions' format \
    "%{$fg[red]%}completing %B%d%b%{$reset_color%}"
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
# warn if there are no matches
zstyle ':completion:*:warnings' format \
    "%{$fg[red]%}No matches for:%{$reset_color%} %d"
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
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr '%F{green}•'
zstyle ':vcs_info:*' unstagedstr '%F{red}•'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%r'
zstyle ':vcs_info:*' enable git svn bzr hg
zstyle ':vcs_info:*' formats '──[%F{red}%s/%b%c%u%m%F{blue}]'

setprompt() {
    local reset="%{$reset_color%}"
    local upper_start='%F{blue}╭─['
    local lower_start='%F{blue}╰'
    local other_start='%F{blue}┄─['
    local other_end=']─╼ ${reset}'
    local userhost='%F{green}%n@%m'
    local sep='%F{blue}]──['
    local startsep='%F{blue}──['
    local endsep='%F{blue}]'
    local fade='%F{blue}────┄'
    local dir='%F{red}%~'
    local date='%F{yellow}%D'
    local dtime='%F{yellow}%T'
    local job="%(1j.${startsep}%F{red}%j job.)%(2j.s.)%(1j.${endsep}.)"
    local vcs='${vcs_info_msg_0_}'
    if [[ -n $RANGER_LEVEL ]]; then
        local ranger="${startsep}%F{red}ranger"
        (( RANGER_LEVEL > 1 )) && ranger+=":$RANGER_LEVEL"
        ranger+="${endsep}"
    else
        local ranger=
    fi
    local rootwarn='%(!.%F{blue}(%F{red}!%F{blue}).)'
    local promptchar='%F{blue}─╼ '
    local n=$'\n'
    local rstatus='%(?..%F{red}╾─[%F{blue}$?%F{red}]──┄)'

    PROMPT="${upper_start}${userhost}${sep}${dir}${sep}${date}${sep}"
    PROMPT+="${dtime}${endsep}${job}${vcs}${ranger}${fade}$n"

    PROMPT+="${lower_start}${rootwarn}${promptchar}${reset}"

    PROMPT2="${other_start}%_${other_end}"
    PROMPT3="${other_start}?${other_end}"
    PROMPT4="${other_start}%N:%i${other_end}"
    RPROMPT="${rstatus}${reset}"
}

setprompt

### Hooks ###
preexec() { # Gets run before a command gets executed
    # Set screen/tmux window title
    [[ $TERM == screen* ]] && echo -ne "\ek$1\e\\"
}
precmd() { # gets run after a command before the prompt
    # Reset screen/tmux window title
    [[ $TERM == screen* ]] && echo -ne "\ekzsh\e\\"
    # Generate vcs_info
    vcs_info
}

### Autorun tmux ###
if [[ -z "$TMUX" && -n "$SSH_CONNECTION" ]]; then
    tmux -2 attach -d
fi

### Syntax highlighting ###
highlight=
for d in zsh-syntax-highlight{,ing}; do
    f="/usr/share/zsh/plugins/$d/zsh-syntax-highlighting.zsh"
    [[ -f "$f" ]] && source "$f" && highlight=true
done
if [[ -n "$highlight" ]]; then
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg=red
    ZSH_HIGHLIGHT_STYLES[path]='bold'
fi

### Perl on mehl ##
if [[ $HOST == mehl.schokokeks.org ]]; then
    eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
    alias cpan='perl -MCPAN -Mlocal::lib -e shell'
fi

### Humble bundle key ###
[[ -f ~/.humblebundle ]] && source ~/.humblebundle
