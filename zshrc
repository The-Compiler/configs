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
source /usr/share/doc/pkgfile/command-not-found.zsh
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

### Variables ###
export BROWSER="google-chrome"
export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="vimpager"
export MANPAGER="less"
export GIT_PAGER="less"
export PATH="$PATH:$HOME/bin"
export VIEW_PDF="evince" # for latex-makefile

### Colors for ls ###
[[ -f ~/.dircolors ]] && eval $(dircolors ~/.dircolors) || eval $(dircolors)

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

### aliases ###
alias ls='ls --color --escape --classify'
alias grep='grep --color=auto'
alias less=$PAGER
alias zless=$PAGER
alias nano='nano --nowrap'
alias scr='screen -U -xRR'
alias s='ssh'
alias m='mosh'
alias hc='herbstclient'
alias yu='yaourt -Suya; sudo abs; sudo pkgfile -u; sudo pacdiffviewer'
alias yi='yaourt -S'
alias yq='yaourt -Si'
alias yl='yaourt -Ql'
alias clock='watch -t -n 0.5 "date +%T | toilet -f bigascii12"'
alias pymath='bpython -i <(echo "from math import *")'
alias newx='xinit /usr/bin/urxvt -- :1'
alias nmapa='nmap -T Aggressive -P0 -sT -p 1-65535'
alias mozilla-sdk='cd /opt/addon-sdk && source bin/activate; cd -'
alias unrarall='for f in *.rar; do d="${f%%.*}"; mkdir "$d"; mv "$f" "$d"; cd "$d"; unrar x "$f" && rm "$f"; cd ..; done'
alias tx='tmux -2 attach -d'
xoj() { for f in "$@"; do xournal "$f" &>/dev/null & disown; done }
pdf() { "$VIEW_PDF" "$@" &>/dev/null & disown }
qr() { qrencode "$1" -o- -t ANSIUTF8; }


paste() {
    opts=('-d' 'name=The Compiler' '--data-urlencode')
    if [[ -n "$1" ]]; then # file
        opts+=("text@$1")
        case $1 in
            *.py) opts+=('-d' 'lang=python') ;;
            *.c) opts+=('-d' 'lang=c') ;;
            *.diff|*.patch) opts+=('-d' 'lang=diff') ;;
            *.sh|*.bash|*.zsh) opts+=('-d' 'lang=bash') ;;
            *.tex) opts+=('-d' 'lang=latex') ;;
            Makefile|*.mk) opts+=('-d' 'lang=make') ;;
        esac
    else
        opts+=('text@-') # stdin
    fi
    curl "${opts[@]}" http://paste.the-compiler.org/api/create
}

sch() {
    cd ~/school/2013/Sem01
    while (( $# > 0 )); do
        cd "$1"
        shift
    done
    ls
}

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
    local rootwarn='%(!.%F{blue}(%F{red}!%F{blue}).)'
    local promptchar='%F{blue}─╼ '
    local n=$'\n'
    local rstatus='%(?..%F{red}╾─[%F{blue}$?%F{red}]──┄)'

    PROMPT="${upper_start}${userhost}${sep}${dir}${sep}${date}${sep}"
    PROMPT+="${dtime}${endsep}${job}${vcs}${fade}$n"

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
if [[ -z "$TMUX" && "$SSH_CONNECTION" ]]; then
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

### Humble bundle key ###
[[ -f ~/.humblebundle ]] && source ~/.humblebundle
