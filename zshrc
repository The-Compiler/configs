# Filename:      /etc/zsh/zshrc
# Purpose:       config file for zsh (z shell)
# Authors:       Florian Bruhin, me@the-compiler.org
#                heavily based on a version by
#                grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2.
# Last change:   Fri, 11 Mar 2011 19:30:45 +0100
################################################################################
# This file is sourced only for interactive shells. It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin
################################################################################

# zsh-refcard-tag documentation: {{{
#   You may notice strange looking comments in this file.
#   These are there for a purpose. grml's zsh-refcard can now be
#   automatically generated from the contents of the actual configuration
#   file. However, we need a little extra information on which comments
#   and what lines of code to take into account (and for what purpose).
#
# Here is what they mean:
#
# List of tags (comment types) used:
#   #a#     Next line contains an important alias, that should
#           be included in the grml-zsh-refcard.
#           (placement tag: @@INSERT-aliases@@)
#   #f#     Next line contains the beginning of an important function.
#           (placement tag: @@INSERT-functions@@)
#   #v#     Next line contains an important variable.
#           (placement tag: @@INSERT-variables@@)
#   #k#     Next line contains an important keybinding.
#           (placement tag: @@INSERT-keybindings@@)
#   #d#     Hashed directories list generation:
#               start   denotes the start of a list of 'hash -d'
#                       definitions.
#               end     denotes its end.
#           (placement tag: @@INSERT-hasheddirs@@)
#   #A#     Abbreviation expansion list generation:
#               start   denotes the beginning of abbreviations.
#               end     denotes their end.
#           Lines within this section that end in '#d .*' provide
#           extra documentation to be included in the refcard.
#           (placement tag: @@INSERT-abbrev@@)
#   #m#     This tag allows you to manually generate refcard entries
#           for code lines that are hard/impossible to parse.
#               Example:
#                   #m# k ESC-h Call the run-help function
#               That would add a refcard entry in the keybindings table
#               for 'ESC-h' with the given comment.
#           So the syntax is: #m# <section> <argument> <comment>
#   #o#     This tag lets you insert entries to the 'other' hash.
#           Generally, this should not be used. It is there for
#           things that cannot be done easily in another way.
#           (placement tag: @@INSERT-other-foobar@@)
#
#   All of these tags (except for m and o) take two arguments, the first
#   within the tag, the other after the tag:
#
#   #<tag><section># <comment>
#
#   Where <section> is really just a number, which are defined by the
#   @secmap array on top of 'genrefcard.pl'. The reason for numbers
#   instead of names is, that for the reader, the tag should not differ
#   much from a regular comment. For zsh, it is a regular comment indeed.
#   The numbers have got the following meanings:
#         0 -> "default"
#         1 -> "system"
#         2 -> "user"
#         3 -> "debian"
#         4 -> "search"
#         5 -> "shortcuts"
#         6 -> "services"
#
#   So, the following will add an entry to the 'functions' table in the
#   'system' section, with a (hopefully) descriptive comment:
#       #f1# Edit an alias via zle
#       edalias() {
#
#   It will then show up in the @@INSERT-aliases-system@@ replacement tag
#   that can be found in 'grml-zsh-refcard.tex.in'.
#   If the section number is omitted, the 'default' section is assumed.
#   Furthermore, in 'grml-zsh-refcard.tex.in' @@INSERT-aliases@@ is
#   exactly the same as @@INSERT-aliases-default@@. If you want a list of
#   *all* aliases, for example, use @@INSERT-aliases-all@@.
#}}}

# zsh profiling {{{
# just execute 'ZSH_PROFILE_RC=1 zsh' and run 'zprof' to get the details
if [[ $ZSH_PROFILE_RC -gt 0 ]] ; then
    zmodload zsh/zprof
fi
# }}}

# load .zshrc.pre to give the user the chance to overwrite the defaults
[[ -r ${HOME}/.zshrc.pre ]] && source ${HOME}/.zshrc.pre

# {{{ check for version/system
# check for versions (compatibility reasons)
is4(){
    [[ $ZSH_VERSION == <4->* ]] && return 0
    return 1
}

is41(){
    [[ $ZSH_VERSION == 4.<1->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is42(){
    [[ $ZSH_VERSION == 4.<2->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is425(){
    [[ $ZSH_VERSION == 4.2.<5->* || $ZSH_VERSION == 4.<3->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is43(){
    [[ $ZSH_VERSION == 4.<3->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

#f1# Checks whether or not you're running grml
isgrml(){
    [[ -f /etc/grml_version ]] && return 0
    return 1
}

#f1# Checks whether or not you're running a grml cd
isgrmlcd(){
    [[ -f /etc/grml_cd ]] && return 0
    return 1
}

if isgrml ; then
#f1# Checks whether or not you're running grml-small
    isgrmlsmall() {
        [[ ${${${(f)"$(</etc/grml_version)"}%% *}##*-} == 'small' ]] && return 0 ; return 1
    }
else
    isgrmlsmall() { return 1 }
fi

isdarwin(){
    [[ $OSTYPE == darwin* ]] && return 0
    return 1
}

#f1# are we running within an utf environment?
isutfenv() {
    case "$LANG $CHARSET $LANGUAGE" in
        *utf*) return 0 ;;
        *UTF*) return 0 ;;
        *)     return 1 ;;
    esac
}

# check for user, if not running as root set $SUDO to sudo
(( EUID != 0 )) && SUDO='sudo' || SUDO=''

# change directory to home on first invocation of zsh
# important for rungetty -> autologin
# Thanks go to Bart Schaefer!
isgrml && checkhome() {
    if [[ -z "$ALREADY_DID_CD_HOME" ]] ; then
        export ALREADY_DID_CD_HOME=$HOME
        cd
    fi
}

# check for zsh v3.1.7+

if ! [[ ${ZSH_VERSION} == 3.1.<7->*      \
     || ${ZSH_VERSION} == 3.<2->.<->*    \
     || ${ZSH_VERSION} == <4->.<->*   ]] ; then

    printf '-!-\n'
    printf '-!- In this configuration we try to make use of features, that only\n'
    printf '-!- require version 3.1.7 of the shell; That way this setup can be\n'
    printf '-!- used with a wide range of zsh versions, while using fairly\n'
    printf '-!- advanced features in all supported versions.\n'
    printf '-!-\n'
    printf '-!- However, you are running zsh version %s.\n' "$ZSH_VERSION"
    printf '-!-\n'
    printf '-!- While this *may* work, it might as well fail.\n'
    printf '-!- Please consider updating to at least version 3.1.7 of zsh.\n'
    printf '-!-\n'
    printf '-!- DO NOT EXPECT THIS TO WORK FLAWLESSLY!\n'
    printf '-!- If it does today, you'\''ve been lucky.\n'
    printf '-!-\n'
    printf '-!- Ye been warned!\n'
    printf '-!-\n'

    function zstyle() { : }
fi

# autoload wrapper - use this one instead of autoload directly
# We need to define this function as early as this, because autoloading
# 'is-at-least()' needs it.
function zrcautoload() {
    setopt local_options extended_glob
    local fdir ffile
    local -i ffound

    ffile=${1}
    (( found = 0 ))
    for fdir in ${fpath} ; do
        [[ -e ${fdir}/${ffile} ]] && (( ffound = 1 ))
    done

    (( ffound == 0 )) && return 1
    if [[ $ZSH_VERSION == 3.1.<6-> || $ZSH_VERSION == <4->* ]] ; then
        autoload -U ${ffile} || return 1
    else
        autoload ${ffile} || return 1
    fi
    return 0
}

# Load is-at-least() for more precise version checks
# Note that this test will *always* fail, if the is-at-least
# function could not be marked for autoloading.
zrcautoload is-at-least || is-at-least() { return 1 }

# }}}

#set the locale stuff {{{
#LANG=de_DE.utf8
#LC_ALL=de_DE.utf8
#export LANG
#export LC_ALL
#}}}

# setting some default values {{{

NOCOR=${NOCOR:-0}
NOMENU=${NOMENU:-0}
NOPRECMD=${NOPRECMD:-0}
BATTERY=${BATTERY:-0}
GRMLSMALL_SPECIFIC=${GRMLSMALL_SPECIFIC:-1}
GRML_ALWAYS_LOAD_ALL=${GRML_ALWAYS_LOAD_ALL:-0}

if isgrmlcd ; then
    GRML_WARN_SKEL=${GRML_WARN_SKEL:-0}
else
    GRML_WARN_SKEL=${GRML_WARN_SKEL:-1}
fi

if (( GRML_WARN_SKEL != 0 )) ; then

function grml_warn_skel_main() {
    printf '
Dear user,

You updated grml'\''s zshrc which brings a major change.
The configuration is kept only in one file, being the global zshrc.
In the past, the configuration was split in two files, with the
second file being the .zshrc file from /etc/skel.

If you have a .zshrc file in your home directory that originally
came from the skel directory, please remove it. This is also the case
if you followed earlier instructions from the grml-zsh-refcard or
from <http://grml.org/console/> on non-grml systems.

Please see the current grml-zsh-refcard (available at
<http://grml.org/zsh/>) for updated installation information. In short,
you don'\''t want a .zshrc.global file. Install the global zshrc to
~/.zshrc and be done.

If you need changes to the configuration, use ~/.zshrc.pre and
~/.zshrc.local.

'
}

function grml_warn_skel_remove() {
    printf 'To remove this warning execute '\''grml_do_not_warn_skel'\''.\n\n'
}

function grml_do_not_warn_skel() {
    printf '# Do not warn about old skel dot-files anymore\n' >>! ~/.zshrc.pre
    printf 'GRML_WARN_SKEL=0\n' >>! ~/.zshrc.pre
}

# let's try to guess how the user uses us.
if is-at-least 4.3.7 ; then
    # funcsourcetrace requires at least version 4.3.7 of zsh.
    GRML_SRC_FILE="${${funcsourcetrace[1]}%:*}"

    grml_warn_skel_main
    case ${GRML_SRC_FILE} in
        (${HOME}/.zshrc.global)
            grml_warn_skel_remove
            printf '\nIt looks like you copied the grml zshrc to '\''~/.zshrc.global'\''.\n'
            printf 'Nowadays you just copy the global zshrc to '\''~/.zshrc'\'' to use\n'
            printf 'it on a non-grml-system.\n'
            ;;
        (${HOME}/.zshrc)
            printf '\nIt looks like you copied the grml zshrc to '\''~/.zshrc'\''.\n'
            printf 'We'\''ll disable this warning automatically for later sessions.\n'
            grml_do_not_warn_skel
            ;;
        (*)
            grml_do_not_warn_skel
            ;;
    esac
else
    grml_warn_skel_main
    grml_warn_skel_remove
fi

unfunction grml_warn_skel_remove grml_warn_skel_main

fi # GRML_WARN_SKEL

# }}}

# utility functions {{{
# this function checks if a command exists and returns either true
# or false. This avoids using 'which' and 'whence', which will
# avoid problems with aliases for which on certain weird systems. :-)
check_com() {
    local -i comonly

    if [[ ${1} == '-c' ]] ; then
        (( comonly = 1 ))
        shift
    else
        (( comonly = 0 ))
    fi

    if (( ${#argv} != 1 )) ; then
        printf 'usage: check_com [-c] <command>\n' >&2
        return 1
    fi

    if (( comonly > 0 )) ; then
        [[ -n ${commands[$1]}  ]] && return 0
        return 1
    fi

    if   [[ -n ${commands[$1]}    ]] \
      || [[ -n ${functions[$1]}   ]] \
      || [[ -n ${aliases[$1]}     ]] \
      || [[ -n ${reswords[(r)$1]} ]] ; then

        return 0
    fi

    return 1
}

# creates an alias and precedes the command with
# sudo if $EUID is not zero.
salias() {
    local only=0 ; local multi=0
    while [[ ${1} == -* ]] ; do
        case ${1} in
            (-o) only=1 ;;
            (-a) multi=1 ;;
            (--) shift ; break ;;
            (-h)
                printf 'usage: salias [-h|-o|-a] <alias-expression>\n'
                printf '  -h      shows this help text.\n'
                printf '  -a      replace '\'' ; '\'' sequences with '\'' ; sudo '\''.\n'
                printf '          be careful using this option.\n'
                printf '  -o      only sets an alias if a preceding sudo would be needed.\n'
                return 0
                ;;
            (*) printf "unkown option: '%s'\n" "${1}" ; return 1 ;;
        esac
        shift
    done

    if (( ${#argv} > 1 )) ; then
        printf 'Too many arguments %s\n' "${#argv}"
        return 1
    fi

    key="${1%%\=*}" ;  val="${1#*\=}"
    if (( EUID == 0 )) && (( only == 0 )); then
        alias -- "${key}=${val}"
    elif (( EUID > 0 )) ; then
        (( multi > 0 )) && val="${val// ; / ; sudo }"
        alias -- "${key}=sudo ${val}"
    fi

    return 0
}

# a "print -l ${(u)foo}"-workaround for pre-4.2.0 shells
# usage: uprint foo
#   Where foo is the *name* of the parameter you want printed.
#   Note that foo is no typo; $foo would be wrong here!
if ! is42 ; then
    uprint () {
        local -a u
        local w
        local parameter=${1}

        if [[ -z ${parameter} ]] ; then
            printf 'usage: uprint <parameter>\n'
            return 1
        fi

        for w in ${(P)parameter} ; do
            [[ -z ${(M)u:#${w}} ]] && u=( ${u} ${w} )
        done

        builtin print -l ${u}
    }
fi

# Check if we can read given files and source those we can.
xsource() {
    if (( ${#argv} < 1 )) ; then
        printf 'usage: xsource FILE(s)...\n' >&2
        return 1
    fi

    while (( ${#argv} > 0 )) ; do
        [[ -r ${1} ]] && source ${1}
        shift
    done
    return 0
}

# Check if we can read a given file and 'cat(1)' it.
xcat() {
    if (( ${#argv} != 1 )) ; then
        printf 'usage: xcat FILE\n' >&2
        return 1
    fi

    [[ -r ${1} ]] && cat ${1}
    return 0
}

# Remove these functions again, they are of use only in these
# setup files. This should be called at the end of .zshrc.
xunfunction() {
    local -a funcs
    funcs=(salias xcat xsource xunfunction zrcautoload)

    for func in $funcs ; do
        [[ -n ${functions[$func]} ]] \
            && unfunction $func
    done
    return 0
}

# this allows us to stay in sync with grml's zshrc and put own
# modifications in ~/.zshrc.local
zrclocal() {
    xsource "${HOME}/.zshrc.local"
    return 0
}

#}}}

# locale setup {{{
if [[ -z "$LANG" ]] ; then
   xsource "/etc/default/locale"
fi

export LANG=${LANG:-en_US.iso885915}
for var in LC_ALL LC_MESSAGES ; do
    [[ -n ${(P)var} ]] && export $var
done

xsource "/etc/sysconfig/keyboard"

TZ=$(xcat /etc/timezone)
# }}}

# check for potentially old files in 'completion.d' {{{
setopt extendedglob
xof=(/etc/zsh/completion.d/*~/etc/zsh/completion.d/_*(N))
if (( ${#xof} > 0 )) ; then
    printf '\n -!- INFORMATION\n\n'
    printf ' -!- %s file(s) not starting with an underscore (_) found in\n' ${#xof}
    printf ' -!- /etc/zsh/completion.d/.\n\n'
    printf ' -!- While this has been the case in old versions of grml-etc-core,\n'
    printf ' -!- recent versions of the grml-zsh-setup have all these files rewritten\n'
    printf ' -!- and renamed. Furthermore, the grml-zsh-setup will *only* add files\n'
    printf ' -!- named _* to that directory.\n\n'
    printf ' -!- If you added functions to completion.d yourself, please consider\n'
    printf ' -!- moving them to /etc/zsh/functions.d/. Files in that directory, not\n'
    printf ' -!- starting with an underscore are marked for automatic loading\n'
    printf ' -!- by default (so that is quite convenient).\n\n'
    printf ' -!- If there are files *not* starting with an underscore from an older\n'
    printf ' -!- grml-etc-core in completion.d, you may safely remove them.\n\n'
    printf ' -!- Delete the files for example via running:\n\n'
    printf "      rm ${xof}\n\n"
    printf ' -!- Note, that this message will *not* go away, unless you yourself\n'
    printf ' -!- resolve the situation manually.\n\n'
    BROKEN_COMPLETION_DIR=1
fi
unset xof
# }}}

# {{{ set some variables
if check_com -c vim ; then
#v#
    export EDITOR=${EDITOR:-vim}
else
    export EDITOR=${EDITOR:-vi}
fi

#v#
export PAGER=${PAGER:-vimpager}
export MANPAGER=less
alias less=$PAGER
alias zless=$PAGER

#v#
export MAIL=${MAIL:-/var/mail/$USER}

# if we don't set $SHELL then aterm, rxvt,.. will use /bin/sh or /bin/bash :-/
export SHELL='/bin/zsh'

# color setup for ls:
check_com -c dircolors && eval $(dircolors -b)
# color setup for ls on OS X:
isdarwin && export CLICOLOR=1

# do MacPorts setup on darwin
if isdarwin && [[ -d /opt/local ]]; then
    # Note: PATH gets set in /etc/zprofile on Darwin, so this can't go into
    # zshenv.
    PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    MANPATH="/opt/local/share/man:$MANPATH"
fi
# do Fink setup on darwin
isdarwin && xsource /sw/bin/init.sh

# completion functions go to /etc/zsh/completion.d
# function files may be put into /etc/zsh/functions.d, from where they
# will be automatically autoloaded.
if [[ -n "$BROKEN_COMPLETION_DIR" ]] ; then
    print 'Warning: not setting completion directories because broken files have been found.' >&2
else
    [[ -d /etc/zsh/completion.d ]] && fpath=( $fpath /etc/zsh/completion.d )
    if [[ -d /etc/zsh/functions.d ]] ; then
        fdir='/etc/zsh/functions.d'
        fpath=( ${fdir} ${fdir}/**/*(/N) ${fpath} )
        for func in ${fdir}/**/[^_]*[^~](N.) ; do
            zrcautoload ${func:t}
        done
        unset fdir
    fi
fi

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath
# }}}

# {{{ keybindings
if [[ "$TERM" != emacs ]] ; then
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M emacs "$terminfo[kend]"  end-of-line
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M vicmd "$terminfo[kend]"  vi-end-of-line
    [[ -z "$terminfo[cuu1]"  ]] || bindkey -M viins "$terminfo[cuu1]"  vi-up-line-or-history
    [[ -z "$terminfo[cuf1]"  ]] || bindkey -M viins "$terminfo[cuf1]"  vi-forward-char
    [[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" vi-up-line-or-history
    [[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" vi-down-line-or-history
    [[ -z "$terminfo[kcuf1]" ]] || bindkey -M viins "$terminfo[kcuf1]" vi-forward-char
    [[ -z "$terminfo[kcub1]" ]] || bindkey -M viins "$terminfo[kcub1]" vi-backward-char
    # ncurses stuff:
    [[ "$terminfo[kcuu1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" vi-up-line-or-history
    [[ "$terminfo[kcud1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" vi-down-line-or-history
    [[ "$terminfo[kcuf1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuf1]/O/[}" vi-forward-char
    [[ "$terminfo[kcub1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcub1]/O/[}" vi-backward-char
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M viins "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M viins "${terminfo[kend]/O/[}"  end-of-line
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M emacs "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M emacs "${terminfo[kend]/O/[}"  end-of-line
fi

## keybindings (run 'bindkeys' for details, more details via man zshzle)
# use emacs style per default:
bindkey -e
# use vi style:
# bindkey -v

#if [[ "$TERM" == screen ]] ; then
bindkey '\e[1~' beginning-of-line       # home
bindkey '\e[4~' end-of-line             # end
bindkey '\e[A'  up-line-or-search       # cursor up
bindkey '\e[B'  down-line-or-search     # <ESC>-

bindkey '^xp'   history-beginning-search-backward
bindkey '^xP'   history-beginning-search-forward
# bindkey -s '^L' "|less\n"             # ctrl-L pipes to less
# bindkey -s '^B' " &\n"                # ctrl-B runs it in the background
# if terminal type is set to 'rxvt':
bindkey '\e[7~' beginning-of-line       # home
bindkey '\e[8~' end-of-line             # end
#fi

# insert unicode character
# usage example: 'ctrl-x i' 00A7 'ctrl-x i' will give you an �
# See for example http://unicode.org/charts/ for unicode characters code
zrcautoload insert-unicode-char
zle -N insert-unicode-char
#k# Insert Unicode character
bindkey '^Xi' insert-unicode-char

# just type 'cd ...' to get 'cd ../..'
#  rationalise-dot() {
#  if [[ $LBUFFER == *.. ]] ; then
#    LBUFFER+=/..
#  else
#    LBUFFER+=.
#  fi
#  }
#  zle -N rationalise-dot
#  bindkey . rationalise-dot

#  bindkey '\eq' push-line-or-edit

## toggle the ,. abbreviation feature on/off
# NOABBREVIATION: default abbreviation-state
#                 0 - enabled (default)
#                 1 - disabled
NOABBREVIATION=${NOABBREVIATION:-0}

grml_toggle_abbrev() {
    if (( ${NOABBREVIATION} > 0 )) ; then
        NOABBREVIATION=0
    else
        NOABBREVIATION=1
    fi
}

zle -N grml_toggle_abbrev
bindkey '^xA' grml_toggle_abbrev

# }}}

# a generic accept-line wrapper {{{

# This widget can prevent unwanted autocorrections from command-name
# to _command-name, rehash automatically on enter and call any number
# of builtin and user-defined widgets in different contexts.
#
# For a broader description, see:
# <http://bewatermyfriend.org/posts/2007/12-26.11-50-38-tooltime.html>
#
# The code is imported from the file 'zsh/functions/accept-line' from
# <http://ft.bewatermyfriend.org/comp/zsh/zsh-dotfiles.tar.bz2>, which
# distributed under the same terms as zsh itself.

# A newly added command will may not be found or will cause false
# correction attempts, if you got auto-correction set. By setting the
# following style, we force accept-line() to rehash, if it cannot
# find the first word on the command line in the $command[] hash.
zstyle ':acceptline:*' rehash true

function Accept-Line() {
    setopt localoptions noksharrays
    local -a subs
    local -xi aldone
    local sub

    zstyle -a ":acceptline:${alcontext}" actions subs

    (( ${#subs} < 1 )) && return 0

    (( aldone = 0 ))
    for sub in ${subs} ; do
        [[ ${sub} == 'accept-line' ]] && sub='.accept-line'
        zle ${sub}

        (( aldone > 0 )) && break
    done
}

function Accept-Line-getdefault() {
    local default_action

    zstyle -s ":acceptline:${alcontext}" default_action default_action
    case ${default_action} in
        ((accept-line|))
            printf ".accept-line"
            ;;
        (*)
            printf ${default_action}
            ;;
    esac
}

function accept-line() {
    setopt localoptions noksharrays
    local -a cmdline
    local -x alcontext
    local buf com fname format msg default_action

    alcontext='default'
    buf="${BUFFER}"
    cmdline=(${(z)BUFFER})
    com="${cmdline[1]}"
    fname="_${com}"

    zstyle -t ":acceptline:${alcontext}" rehash \
        && [[ -z ${commands[$com]} ]]           \
        && rehash

    if    [[ -n ${reswords[(r)$com]} ]] \
       || [[ -n ${aliases[$com]}     ]] \
       || [[ -n ${functions[$com]}   ]] \
       || [[ -n ${builtins[$com]}    ]] \
       || [[ -n ${commands[$com]}    ]] ; then

        # there is something sensible to execute, just do it.
        alcontext='normal'
        zle Accept-Line

        default_action=$(Accept-Line-getdefault)
        zstyle -T ":acceptline:${alcontext}" call_default \
            && zle ${default_action}
        return
    fi

    if    [[ -o correct              ]] \
       || [[ -o correctall           ]] \
       && [[ -n ${functions[$fname]} ]] ; then

        # nothing there to execute but there is a function called
        # _command_name; a completion widget. Makes no sense to
        # call it on the commandline, but the correct{,all} options
        # will ask for it nevertheless, so warn the user.
        if [[ ${LASTWIDGET} == 'accept-line' ]] ; then
            # Okay, we warned the user before, he called us again,
            # so have it his way.
            alcontext='force'
            zle Accept-Line

            default_action=$(Accept-Line-getdefault)
            zstyle -T ":acceptline:${alcontext}" call_default \
                && zle ${default_action}
            return
        fi

        # prepare warning message for the user, configurable via zstyle.
        zstyle -s ":acceptline:${alcontext}" compwarnfmt msg

        if [[ -z ${msg} ]] ; then
            msg="%c will not execute and completion %f exists."
        fi

        zformat -f msg "${msg}" "c:${com}" "f:${fname}"

        zle -M -- "${msg}"
        return
    elif [[ -n ${buf//[$' \t\n']##/} ]] ; then
        # If we are here, the commandline contains something that is not
        # executable, which is neither subject to _command_name correction
        # and is not empty. might be a variable assignment
        alcontext='misc'
        zle Accept-Line

        default_action=$(Accept-Line-getdefault)
        zstyle -T ":acceptline:${alcontext}" call_default \
            && zle ${default_action}
        return
    fi

    # If we got this far, the commandline only contains whitespace, or is empty.
    alcontext='empty'
    zle Accept-Line

    default_action=$(Accept-Line-getdefault)
    zstyle -T ":acceptline:${alcontext}" call_default \
        && zle ${default_action}
}

zle -N accept-line
zle -N Accept-Line

# }}}

# power completion - abbreviation expansion {{{
# power completion / abbreviation expansion / buffer expansion
# see http://zshwiki.org/home/examples/zleiab for details
# less risky than the global aliases but powerful as well
# just type the abbreviation key and afterwards ',.' to expand it
declare -A abk
setopt extendedglob
setopt interactivecomments
abk=(
# key  # value                (#d additional doc string)
#A# start
    '...' '../..'
    '....' '../../..'
    'BG' '& exit'
    'C' '| wc -l'
    'G' '|& grep --color=auto'
    'H' '| head'
    'Hl' ' --help |& less -r'      #d (Display help in pager)
    'L' '| less'
    'LL' '|& less -r'
    'M' '| most'
    'N' '&>/dev/null'              #d (No Output)
    'R' '| tr A-z N-za-m'          #d (ROT13)
    'SL' '| sort | less'
    'S' '| sort -u'
    'T' '| tail'
    'V' '|& vim -'
#A# end
    'co' "./configure && make && sudo make install"
)

globalias() {
    local MATCH

    if (( NOABBREVIATION > 0 )) ; then
        LBUFFER="${LBUFFER},."
        return 0
    fi

    matched_chars='[.-|_a-zA-Z0-9]#'
    LBUFFER=${LBUFFER%%(#m)[.-|_a-zA-Z0-9]#}
    LBUFFER+=${abk[$MATCH]:-$MATCH}
}

zle -N globalias
bindkey ",." globalias
# }}}

# {{{ autoloading
zrcautoload zmv    # who needs mmv or rename?
zrcautoload history-search-end

# we don't want to quote/espace URLs on our own...
# if autoload -U url-quote-magic ; then
#    zle -N self-insert url-quote-magic
#    zstyle ':url-quote-magic:*' url-metas '*?[]^()~#{}='
# else
#    print 'Notice: no url-quote-magic available :('
# fi
alias url-quote='autoload -U url-quote-magic ; zle -N self-insert url-quote-magic'

#m# k ESC-h Call \kbd{run-help} for the 1st word on the command line
alias run-help >&/dev/null && unalias run-help
zrcautoload run-help # use via 'esc-h'

# completion system
if zrcautoload compinit && compinit 2>/dev/null ; then
    compinit 2>/dev/null || print 'Notice: no compinit available :('
else
    print 'Notice: no compinit available :('
    function zstyle { }
    function compdef { }
fi

is4 && zrcautoload zed # use ZLE editor to edit a file or function

is4 && \
for mod in complist deltochar mathfunc ; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done

# autoload zsh modules when they are referenced
if is4 ; then
    tmpargs=(
        a   stat
        a   zpty
        ap  mapfile
    )

    while (( ${#tmpargs} > 0 )) ; do
        zmodload -${tmpargs[1]} zsh/${tmpargs[2]} ${tmpargs[2]}
        shift 2 tmpargs
    done
    unset tmpargs
fi

if is4 && zrcautoload insert-files && zle -N insert-files ; then
    #k# Insert files
    bindkey "^Xf" insert-files # C-x-f
fi

bindkey ' '   magic-space    # also do history expansion on space
#k# Trigger menu-complete
bindkey '\ei' menu-complete  # menu completion via esc-i

# press esc-e for editing command line in $EDITOR or $VISUAL
if is4 && zrcautoload edit-command-line && zle -N edit-command-line ; then
    #k# Edit the current line in \kbd{\$EDITOR}
    bindkey '\ee' edit-command-line
fi

if is4 && [[ -n ${(k)modules[zsh/complist]} ]] ; then
    #k# menu selection: pick item but stay in the menu
    bindkey -M menuselect '\e^M' accept-and-menu-complete

    # accept a completion and try to complete again by using menu
    # completion; very useful with completing directories
    # by using 'undo' one's got a simple file browser
    bindkey -M menuselect '^o' accept-and-infer-next-history
fi

# press "ctrl-e d" to insert the actual date in the form yyyy-mm-dd
_bkdate() { BUFFER="$BUFFER$(date '+%F')"; CURSOR=$#BUFFER; }
zle -N _bkdate

#k# Insert a timestamp on the command line (yyyy-mm-dd)
bindkey '^Ed' _bkdate

# press esc-m for inserting last typed word again (thanks to caphuso!)
insert-last-typed-word() { zle insert-last-word -- 0 -1 };
zle -N insert-last-typed-word;

#k# Insert last typed word
bindkey "\em" insert-last-typed-word

#k# Shortcut for \kbd{fg<enter>}
bindkey -s '^z' "fg\n"

# run command line as user root via sudo:
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
}
zle -N sudo-command-line

#k# Put the current command line into a \kbd{sudo} call
bindkey "^Os" sudo-command-line

### jump behind the first word on the cmdline.
### useful to add options.
function jump_after_first_word() {
    local words
    words=(${(z)BUFFER})

    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}
zle -N jump_after_first_word

bindkey '^x1' jump_after_first_word

# }}}

# {{{ set some important options
# Please update these tags, if you change the umask settings below.
#o# r_umask     002
#o# r_umaskstr  rwxrwxr-x
#o# umask       022
#o# umaskstr    rwxr-xr-x
(( EUID != 0 )) && umask 002 || umask 022

# history:
setopt append_history       # append history list to the history file (important for multiple parallel zsh sessions!)
is4 && setopt SHARE_HISTORY # import new commands from the history file also in other zsh-session
setopt extended_history     # save each command's beginning timestamp and the duration to the history file
is4 && setopt histignorealldups # If  a  new  command  line being added to the history
                            # list duplicates an older one, the older command is removed from the list
setopt histignorespace      # remove command lines from the history list when
                            # the first character on the line is a space
setopt auto_cd              # if a command is issued that can't be executed as a normal command,
                            # and the command is the name of a directory, perform the cd command to that directory
setopt extended_glob        # in order to use #, ~ and ^ for filename generation
                            # grep word *~(*.gz|*.bz|*.bz2|*.zip|*.Z) ->
                            # -> searches for word not in compressed files
                            # don't forget to quote '^', '~' and '#'!
setopt longlistjobs         # display PID when suspending processes as well
setopt notify               # report the status of backgrounds jobs immediately
setopt hash_list_all        # Whenever a command completion is attempted, make sure \
                            # the entire command path is hashed first.
setopt completeinword       # not just at the end
setopt nohup                # and don't kill them, either
setopt auto_pushd           # make cd push the old directory onto the directory stack.
setopt nonomatch            # try to avoid the 'zsh: no matches found...'
setopt nobeep               # avoid "beep"ing
setopt pushd_ignore_dups    # don't push the same dir twice.
setopt noglobdots           # * shouldn't match dotfiles. ever.

MAILCHECK=30       # mailchecks
REPORTTIME=5       # report about cpu-/system-/user-time of command if running longer than 5 seconds
watch=(notme root) # watch for everyone but me and root

# only slash should be considered as a word separator:
slash-backward-kill-word() {
    local WORDCHARS="${WORDCHARS:s@/@}"
    # zle backward-word
    zle backward-kill-word
}
zle -N slash-backward-kill-word

#k# Kill everything in a word up to its last \kbd{/}
bindkey '\ev' slash-backward-kill-word

# }}}

# {{{ history

ZSHDIR=$HOME/.zsh

#v#
HISTFILE=$HOME/.zsh_history
isgrmlcd && HISTSIZE=500  || HISTSIZE=5000
isgrmlcd && SAVEHIST=1000 || SAVEHIST=10000 # useful for setopt append_history

# }}}

# dirstack handling {{{

DIRSTACKSIZE=${DIRSTACKSIZE:-20}
DIRSTACKFILE=${DIRSTACKFILE:-${HOME}/.zdirs}

if [[ -f ${DIRSTACKFILE} ]] && [[ ${#dirstack[*]} -eq 0 ]] ; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    # "cd -" won't work after login by just setting $OLDPWD, so
    [[ -d $dirstack[0] ]] && cd $dirstack[0] && cd $OLDPWD
fi

chpwd() {
    if is42 ; then
        builtin print -l ${(u)dirstack} >! ${DIRSTACKFILE}
    else
        uprint dirstack >! ${DIRSTACKFILE}
    fi
}

# }}}

# {{{ display battery status on right side of prompt via running 'BATTERY=1 zsh'
if [[ $BATTERY -gt 0 ]] ; then
    if ! check_com -c acpi ; then
        BATTERY=0
    fi
fi

battery() {
if [[ $BATTERY -gt 0 ]] ; then
    PERCENT="${${"$(acpi 2>/dev/null)"}/(#b)[[:space:]]##Battery <->: [^0-9]##, (<->)%*/${match[1]}}"
    if [[ -z "$PERCENT" ]] ; then
        PERCENT='acpi not present'
    else
        if [[ "$PERCENT" -lt 20 ]] ; then
            PERCENT="warning: ${PERCENT}%%"
        else
            PERCENT="${PERCENT}%%"
        fi
    fi
fi
}
# }}}

# set colors for use in prompts {{{
if zrcautoload colors && colors 2>/dev/null ; then
    BLUE="%{${fg[blue]}%}"
    RED="%{${fg_bold[red]}%}"
    GREEN="%{${fg[green]}%}"
    CYAN="%{${fg[cyan]}%}"
    MAGENTA="%{${fg[magenta]}%}"
    YELLOW="%{${fg[yellow]}%}"
    WHITE="%{${fg[white]}%}"
    NO_COLOUR="%{${reset_color}%}"
else
    BLUE=$'%{\e[1;34m%}'
    RED=$'%{\e[1;31m%}'
    GREEN=$'%{\e[1;32m%}'
    CYAN=$'%{\e[1;36m%}'
    WHITE=$'%{\e[1;37m%}'
    MAGENTA=$'%{\e[1;35m%}'
    YELLOW=$'%{\e[1;33m%}'
    NO_COLOUR=$'%{\e[0m%}'
fi

# }}}

# gather version control information for inclusion in a prompt {{{

if ! is41 ; then
    # Be quiet about version problems in grml's zshrc as the user cannot disable
    # loading vcs_info() as it is *in* the zshrc - as you can see. :-)
    # Just unset most probable variables and disable vcs_info altogether.
    local -i i
    for i in {0..9} ; do
        unset VCS_INFO_message_${i}_
    done
    zstyle ':vcs_info:*' enable false
fi

# The following code is imported from the file 'zsh/functions/vcs_info'
# from <http://ft.bewatermyfriend.org/comp/zsh/zsh-dotfiles.tar.bz2>,
# which distributed under the same terms as zsh itself.

# we will be using two variables, so let the code know now.
zstyle ':vcs_info:*' max-exports 2

# vcs_info() documentation:
#{{{
# REQUIREMENTS:
#{{{
#     This functionality requires zsh version >= 4.1.*.
#}}}
#
# LOADING:
#{{{
# To load vcs_info(), copy this file to your $fpath[] and do:
#   % autoload -Uz vcs_info && vcs_info
#
# To work, vcs_info() needs 'setopt prompt_subst' in your setup.
#}}}
#
# QUICKSTART:
#{{{
# To get vcs_info() working quickly (including colors), you can do the
# following (assuming, you loaded vcs_info() properly - see above):
#
# % RED=$'%{\e[31m%}'
# % GR=$'%{\e[32m%}'
# % MA=$'%{\e[35m%}'
# % YE=$'%{\e[33m%}'
# % NC=$'%{\e[0m%}'
#
# % zstyle ':vcs_info:*' actionformats \
#       "${MA}(${NC}%s${MA})${YE}-${MA}[${GR}%b${YE}|${RED}%a${MA}]${NC} "
#
# % zstyle ':vcs_info:*' formats       \
#       "${MA}(${NC}%s${MA})${Y}-${MA}[${GR}%b${MA}]${NC}%} "
#
# % zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YE}%r"
#
# % precmd () { vcs_info }
# % PS1='${MA}[${GR}%n${MA}] ${MA}(${RED}%!${MA}) ${YE}%3~ ${VCS_INFO_message_0_}${NC}%# '
#
# Obviously, the las two lines are there for demonstration: You need to
# call vcs_info() from your precmd() function (see 'SPECIAL FUNCTIONS' in
# 'man zshmisc'). Once that is done you need a *single* quoted
# '${VCS_INFO_message_0_}' in your prompt.
#
# Now call the 'vcs_info_printsys' utility from the command line:
#
# % vcs_info_printsys
# # list of supported version control backends:
# # disabled systems are prefixed by a hash sign (#)
# git
# hg
# bzr
# darcs
# svk
# mtn
# svn
# cvs
# cdv
# tla
# # flavours (cannot be used in the disable style; they
# # are disabled with their master [git-svn -> git]):
# git-p4
# git-svn
#
# Ten version control backends as you can see. You may not want all
# of these. Because there is no point in running the code to detect
# systems you do not use. ever. So, there is a way to disable some
# backends altogether:
#
# % zstyle ':vcs_info:*' disable bzr cdv darcs mtn svk tla
#
# If you rerun 'vcs_info_printsys' now, you will see the backends listed
# in the 'disable' style marked as diabled by a hash sign. That means the
# detection of these systems is skipped *completely*. No wasted time there.
#
# For more control, read the reference below.
#}}}
#
# CONFIGURATION:
#{{{
# The vcs_info() feature can be configured via zstyle.
#
# First, the context in which we are working:
#       :vcs_info:<vcs-string>:<user-context>
#
# ...where <vcs-string> is one of:
#   - git, git-svn, git-p4, hg, darcs, bzr, cdv, mtn, svn, cvs, svk or tla.
#
# ...and <user-context> is a freely configurable string, assignable by the
# user as the first argument to vcs_info() (see its description below).
#
# There is are three special values for <vcs-string>: The first is named
# 'init', that is in effect as long as there was no decision what vcs
# backend to use. The second is 'preinit; it is used *before* vcs_info()
# is run, when initializing the data exporting variables. The third
# special value is 'formats' and is used by the 'vcs_info_lastmsg' for
# looking up its styles.
#
# There are two pre-defined values for <user-context>:
#   default  - the one used if none is specified
#   command  - used by vcs_info_lastmsg to lookup its styles.
#
# You may *not* use 'print_systems_' as a user-context string, because it
# is used internally.
#
# You can of course use ':vcs_info:*' to match all VCSs in all
# user-contexts at once.
#
# Another special context is 'formats', which is used by the
# vcs_info_lastmsg() utility function (see below).
#
#
# This is a description of all styles, that are looked up:
#   formats             - A list of formats, used when actionformats is not
#                         used (which is most of the time).
#   actionformats       - A list of formats, used if a there is a special
#                         action going on in your current repository;
#                         (like an interactive rebase or a merge conflict)
#   branchformat        - Some backends replace %b in the formats and
#                         actionformats styles above, not only by a branch
#                         name but also by a revision number. This style
#                         let's you modify how that string should look like.
#   nvcsformats         - These "formats" are exported, when we didn't detect
#                         a version control system for the current directory.
#                         This is useful, if you want vcs_info() to completely
#                         take over the generation of your prompt.
#                         You would do something like
#                           PS1='${VCS_INFO_message_0_}'
#                         to accomplish that.
#   max-exports         - Defines the maximum number if VCS_INFO_message_*_
#                         variables vcs_info() will export.
#   enable              - Checked in the 'init' context. If set to false,
#                         vcs_info() will do nothing.
#   disable             - Provide a list of systems, you don't want
#                         the vcs_info() to check for repositories
#                         (checked in the 'init' context, too).
#   disable-patterns    - A list of patterns that are checked against $PWD.
#                         If the pattern matches, vcs_info will be disabled.
#                         Say, ~/.zsh is a directory under version control,
#                         in which you do not want vcs_info to be active, do:
#                         zstyle ':vcs_info:*' disable-patterns "$HOME/.zsh+(|/*)"
#   use-simple          - If there are two different ways of gathering
#                         information, you can select the simpler one
#                         by setting this style to true; the default
#                         is to use the not-that-simple code, which is
#                         potentially a lot slower but might be more
#                         accurate in all possible cases.
#   use-prompt-escapes  - determines if we assume that the assembled
#                         string from vcs_info() includes prompt escapes.
#                         (Used by vcs_info_lastmsg().
#
# The use-simple style is only available for the bzr backend.
#
# The default values for these in all contexts are:
#   formats             " (%s)-[%b|%a]-"
#   actionformats       " (%s)-[%b]-"
#   branchformat        "%b:%r" (for bzr, svn and svk)
#   nvcsformats         ""
#   max-exports         2
#   enable              true
#   disable             (empty list)
#   disable-patterns    (empty list)
#   use-simple          false
#   use-prompt-escapes  true
#
#
# In normal formats and actionformats, the following replacements
# are done:
#   %s  - The vcs in use (git, hg, svn etc.)
#   %b  - Information about the current branch.
#   %a  - An identifier, that describes the action.
#         Only makes sense in actionformats.
#   %R  - base directory of the repository.
#   %r  - repository name
#         If %R is '/foo/bar/repoXY', %r is 'repoXY'.
#   %S  - subdirectory within a repository. if $PWD is
#         '/foo/bar/reposXY/beer/tasty', %S is 'beer/tasty'.
#
#
# In branchformat these replacements are done:
#   %b  - the branch name
#   %r  - the current revision number
#
# Not all vcs backends have to support all replacements.
# nvcsformat does not perform *any* replacements. It is just a string.
#}}}
#
# ODDITIES:
#{{{
# If you want to use the %b (bold off) prompt expansion in 'formats', which
# expands %b itself, use %%b. That will cause the vcs_info() expansion to
# replace %%b with %b. So zsh's prompt expansion mechanism can handle it.
# Similarly, to hand down %b from branchformat, use %%%%b. Sorry for this
# inconvenience, but it cannot be easily avoided. Luckily we do not clash
# with a lot of prompt expansions and this only needs to be done for those.
# See 'man zshmisc' for details about EXPANSION OF PROMPT SEQUENCES.
#}}}
#
# FUNCTION DESCRIPTIONS (public API):
#{{{
#   vcs_info()
#       The main function, that runs all backends and assembles
#       all data into ${VCS_INFO_message_*_}. This is the function
#       you want to call from precmd() if you want to include
#       up-to-date information in your prompt (see VARIABLE
#       DESCRIPTION below).
#
#   vcs_info_printsys()
#       Prints a list of all supported version control systems.
#       Useful to find out possible contexts (and which of them are enabled)
#       or values for the 'disable' style.
#
#   vcs_info_lastmsg()
#       Outputs the last ${VCS_INFO_message_*_} value. Takes into account
#       the value of the use-prompt-escapes style in ':vcs_info:formats'.
#       It also only prints max-exports values.
#
# All functions named VCS_INFO_* are for internal use only.
#}}}
#
# VARIABLE DESCRIPTION:
#{{{
#   ${VCS_INFO_message_N_}    (Note the trailing underscore)
#       Where 'N' is an integer, eg: VCS_INFO_message_0_
#       These variables are the storage for the informational message the
#       last vcs_info() call has assembled. These are strongly connected
#       to the formats, actionformats and nvcsformats styles described
#       above. Those styles are lists. the first member of that list gets
#       expanded into ${VCS_INFO_message_0_}, the second into
#       ${VCS_INFO_message_1_} and the Nth into ${VCS_INFO_message_N-1_}.
#       These parameters are exported into the environment.
#       (See the max-exports style above.)
#}}}
#
# EXAMPLES:
#{{{
#   Don't use vcs_info at all (even though it's in your prompt):
#   % zstyle ':vcs_info:*' enable false
#
#   Disable the backends for bzr and svk:
#   % zstyle ':vcs_info:*' disable bzr svk
#
#   Provide a special formats for git:
#   % zstyle ':vcs_info:git:*' formats       ' GIT, BABY! [%b]'
#   % zstyle ':vcs_info:git:*' actionformats ' GIT ACTION! [%b|%a]'
#
#   Use the quicker bzr backend (if you do, please report if it does
#   the-right-thing[tm] - thanks):
#   % zstyle ':vcs_info:bzr:*' use-simple true
#
#   Display the revision number in yellow for bzr and svn:
#   % zstyle ':vcs_info:(svn|bzr):*' branchformat '%b%{'${fg[yellow]}'%}:%r'
#
# If you want colors, make sure you enclose the color codes in %{...%},
# if you want to use the string provided by vcs_info() in prompts.
#
# Here is how to print the vcs infomation as a command:
#   % alias vcsi='vcs_info command; vcs_info_lastmsg'
#
#   This way, you can even define different formats for output via
#   vcs_info_lastmsg() in the ':vcs_info:command:*' namespace.
#}}}
#}}}
# utilities
VCS_INFO_adjust () { #{{{
    [[ -n ${vcs_comm[overwrite_name]} ]] && vcs=${vcs_comm[overwrite_name]}
    return 0
}
# }}}
VCS_INFO_check_com () { #{{{
    (( ${+commands[$1]} )) && [[ -x ${commands[$1]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_formats () { # {{{
    setopt localoptions noksharrays
    local action=$1 branch=$2 base=$3
    local msg
    local -i i

    if [[ -n ${action} ]] ; then
        zstyle -a ":vcs_info:${vcs}:${usercontext}" actionformats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]-'
    else
        zstyle -a ":vcs_info:${vcs}:${usercontext}" formats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]-'
    fi

    (( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=()
    for i in {1..${#msgs}} ; do
        zformat -f msg ${msgs[$i]}                      \
                        a:${action}                     \
                        b:${branch}                     \
                        r:${base:t}                     \
                        s:${vcs}                        \
                        R:${base}                       \
                        S:"$(VCS_INFO_reposub ${base})"
        msgs[$i]=${msg}
    done
    return 0
}
# }}}
VCS_INFO_maxexports () { #{{{
    zstyle -s ":vcs_info:${vcs}:${usercontext}" "max-exports" maxexports || maxexports=2
    if [[ ${maxexports} != <-> ]] || (( maxexports < 1 )); then
        printf 'vcs_info(): expecting numeric arg >= 1 for max-exports (got %s).\n' ${maxexports}
        printf 'Defaulting to 2.\n'
        maxexports=2
    fi
}
# }}}
VCS_INFO_nvcsformats () { #{{{
    setopt localoptions noksharrays
    local c v

    if [[ $1 == 'preinit' ]] ; then
        c=default
        v=preinit
    fi
    zstyle -a ":vcs_info:${v:-$vcs}:${c:-$usercontext}" nvcsformats msgs
    (( ${#msgs} > maxexports )) && msgs[${maxexports},-1]=()
}
# }}}
VCS_INFO_realpath () { #{{{
    # a portable 'readlink -f'
    # forcing a subshell, to ensure chpwd() is not removed
    # from the calling shell (if VCS_INFO_realpath() is called
    # manually).
    (
        (( ${+functions[chpwd]} )) && unfunction chpwd
        setopt chaselinks
        cd $1 2>/dev/null && pwd
    )
}
# }}}
VCS_INFO_reposub () { #{{{
    setopt localoptions extendedglob
    local base=${1%%/##}

    [[ ${PWD} == ${base}/* ]] || {
        printf '.'
        return 1
    }
    printf '%s' ${PWD#$base/}
    return 0
}
# }}}
VCS_INFO_set () { #{{{
    setopt localoptions noksharrays
    local -i i j

    if [[ $1 == '--clear' ]] ; then
        for i in {0..9} ; do
            unset VCS_INFO_message_${i}_
        done
    fi
    if [[ $1 == '--nvcs' ]] ; then
        [[ $2 == 'preinit' ]] && (( maxexports == 0 )) && (( maxexports = 1 ))
        for i in {0..$((maxexports - 1))} ; do
            typeset -gx VCS_INFO_message_${i}_=
        done
        VCS_INFO_nvcsformats $2
    fi

    (( ${#msgs} - 1 < 0 )) && return 0
    for i in {0..$(( ${#msgs} - 1 ))} ; do
        (( j = i + 1 ))
        typeset -gx VCS_INFO_message_${i}_=${msgs[$j]}
    done
    return 0
}
# }}}
# information gathering
VCS_INFO_bzr_get_data () { # {{{
    setopt localoptions noksharrays
    local bzrbase bzrbr
    local -a bzrinfo

    if zstyle -t ":vcs_info:${vcs}:${usercontext}" "use-simple" ; then
        bzrbase=${vcs_comm[basedir]}
        bzrinfo[2]=${bzrbase:t}
        if [[ -f ${bzrbase}/.bzr/branch/last-revision ]] ; then
            bzrinfo[1]=$(< ${bzrbase}/.bzr/branch/last-revision)
            bzrinfo[1]=${${bzrinfo[1]}%% *}
        fi
    else
        bzrbase=${${(M)${(f)"$( bzr info )"}:# ##branch\ root:*}/*: ##/}
        bzrinfo=( ${${${(M)${(f)"$( bzr version-info )"}:#(#s)(revno|branch-nick)*}/*: /}/*\//} )
        bzrbase="$(VCS_INFO_realpath ${bzrbase})"
    fi

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat bzrbr || bzrbr="%b:%r"
    zformat -f bzrbr "${bzrbr}" "b:${bzrinfo[2]}" "r:${bzrinfo[1]}"
    VCS_INFO_formats '' "${bzrbr}" "${bzrbase}"
    return 0
}
# }}}
VCS_INFO_cdv_get_data () { # {{{
    local cdvbase

    cdvbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${cdvbase:t}" "${cdvbase}"
    return 0
}
# }}}
VCS_INFO_cvs_get_data () { # {{{
    local cvsbranch cvsbase basename

    cvsbase="."
    while [[ -d "${cvsbase}/../CVS" ]]; do
        cvsbase="${cvsbase}/.."
    done
    cvsbase="$(VCS_INFO_realpath ${cvsbase})"
    cvsbranch=$(< ./CVS/Repository)
    basename=${cvsbase:t}
    cvsbranch=${cvsbranch##${basename}/}
    [[ -z ${cvsbranch} ]] && cvsbranch=${basename}
    VCS_INFO_formats '' "${cvsbranch}" "${cvsbase}"
    return 0
}
# }}}
VCS_INFO_darcs_get_data () { # {{{
    local darcsbase

    darcsbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${darcsbase:t}" "${darcsbase}"
    return 0
}
# }}}
VCS_INFO_git_getaction () { #{{{
    local gitaction='' gitdir=$1
    local tmp

    for tmp in "${gitdir}/rebase-apply" \
               "${gitdir}/rebase"       \
               "${gitdir}/../.dotest" ; do
        if [[ -d ${tmp} ]] ; then
            if   [[ -f "${tmp}/rebasing" ]] ; then
                gitaction="rebase"
            elif [[ -f "${tmp}/applying" ]] ; then
                gitaction="am"
            else
                gitaction="am/rebase"
            fi
            printf '%s' ${gitaction}
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge/interactive" \
               "${gitdir}/.dotest-merge/interactive" ; do
        if [[ -f "${tmp}" ]] ; then
            printf '%s' "rebase-i"
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge" \
               "${gitdir}/.dotest-merge" ; do
        if [[ -d "${tmp}" ]] ; then
            printf '%s' "rebase-m"
            return 0
        fi
    done

    if [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        printf '%s' "merge"
        return 0
    fi

    if [[ -f "${gitdir}/BISECT_LOG" ]] ; then
        printf '%s' "bisect"
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_git_getbranch () { #{{{
    local gitbranch gitdir=$1
    local gitsymref='git symbolic-ref HEAD'

    if    [[ -d "${gitdir}/rebase-apply" ]] \
       || [[ -d "${gitdir}/rebase" ]]       \
       || [[ -d "${gitdir}/../.dotest" ]]   \
       || [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"
        [[ -z ${gitbranch} ]] && [[ -r ${gitdir}/rebase-apply/head-name ]] \
            && gitbranch="$(< ${gitdir}/rebase-apply/head-name)"

    elif   [[ -f "${gitdir}/rebase-merge/interactive" ]] \
        || [[ -d "${gitdir}/rebase-merge" ]] ; then
        gitbranch="$(< ${gitdir}/rebase-merge/head-name)"

    elif   [[ -f "${gitdir}/.dotest-merge/interactive" ]] \
        || [[ -d "${gitdir}/.dotest-merge" ]] ; then
        gitbranch="$(< ${gitdir}/.dotest-merge/head-name)"

    else
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"

        if [[ $? -ne 0 ]] ; then
            gitbranch="$(git describe --exact-match HEAD 2>/dev/null)"

            if [[ $? -ne 0 ]] ; then
                gitbranch="${${"$(< $gitdir/HEAD)"}[1,7]}..."
            fi
        fi
    fi

    printf '%s' "${gitbranch##refs/heads/}"
    return 0
}
# }}}
VCS_INFO_git_get_data () { # {{{
    setopt localoptions extendedglob
    local gitdir gitbase gitbranch gitaction

    gitdir=${vcs_comm[gitdir]}
    gitbranch="$(VCS_INFO_git_getbranch ${gitdir})"

    if [[ -z ${gitdir} ]] || [[ -z ${gitbranch} ]] ; then
        return 1
    fi

    VCS_INFO_adjust
    gitaction="$(VCS_INFO_git_getaction ${gitdir})"
    gitbase=${PWD%/${$( git rev-parse --show-prefix )%/##}}
    VCS_INFO_formats "${gitaction}" "${gitbranch}" "${gitbase}"
    return 0
}
# }}}
VCS_INFO_hg_get_data () { # {{{
    local hgbranch hgbase

    hgbase=${vcs_comm[basedir]}
    hgbranch=$(< ${hgbase}/.hg/branch)
    VCS_INFO_formats '' "${hgbranch}" "${hgbase}"
    return 0
}
# }}}
VCS_INFO_mtn_get_data () { # {{{
    local mtnbranch mtnbase

    mtnbase=${vcs_comm[basedir]}
    mtnbranch=${${(M)${(f)"$( mtn status )"}:#(#s)Current branch:*}/*: /}
    VCS_INFO_formats '' "${mtnbranch}" "${mtnbase}"
    return 0
}
# }}}
VCS_INFO_svk_get_data () { # {{{
    local svkbranch svkbase

    svkbase=${vcs_comm[basedir]}
    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svkbranch || svkbranch="%b:%r"
    zformat -f svkbranch "${svkbranch}" "b:${vcs_comm[branch]}" "r:${vcs_comm[revision]}"
    VCS_INFO_formats '' "${svkbranch}" "${svkbase}"
    return 0
}
# }}}
VCS_INFO_svn_get_data () { # {{{
    setopt localoptions noksharrays
    local svnbase svnbranch
    local -a svninfo

    svnbase="."
    while [[ -d "${svnbase}/../.svn" ]]; do
        svnbase="${svnbase}/.."
    done
    svnbase="$(VCS_INFO_realpath ${svnbase})"
    svninfo=( ${${${(M)${(f)"$( svn info )"}:#(#s)(URL|Revision)*}/*: /}/*\//} )

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svnbranch || svnbranch="%b:%r"
    zformat -f svnbranch "${svnbranch}" "b:${svninfo[1]}" "r:${svninfo[2]}"
    VCS_INFO_formats '' "${svnbranch}" "${svnbase}"
    return 0
}
# }}}
VCS_INFO_tla_get_data () { # {{{
    local tlabase tlabranch

    tlabase="$(VCS_INFO_realpath ${vcs_comm[basedir]})"
    # tree-id gives us something like 'foo@example.com/demo--1.0--patch-4', so:
    tlabranch=${${"$( tla tree-id )"}/*\//}
    VCS_INFO_formats '' "${tlabranch}" "${tlabase}"
    return 0
}
# }}}
# detection
VCS_INFO_detect_by_dir() { #{{{
    local dirname=$1
    local basedir="." realbasedir

    realbasedir="$(VCS_INFO_realpath ${basedir})"
    while [[ ${realbasedir} != '/' ]]; do
        if [[ -n ${vcs_comm[detect_need_file]} ]] ; then
            [[ -d ${basedir}/${dirname} ]] && \
            [[ -f ${basedir}/${dirname}/${vcs_comm[detect_need_file]} ]] && \
                break
        else
            [[ -d ${basedir}/${dirname} ]] && break
        fi

        basedir=${basedir}/..
        realbasedir="$(VCS_INFO_realpath ${basedir})"
    done

    [[ ${realbasedir} == "/" ]] && return 1
    vcs_comm[basedir]=${realbasedir}
    return 0
}
# }}}
VCS_INFO_bzr_detect() { #{{{
    VCS_INFO_check_com bzr || return 1
    vcs_comm[detect_need_file]=branch/format
    VCS_INFO_detect_by_dir '.bzr'
    return $?
}
# }}}
VCS_INFO_cdv_detect() { #{{{
    VCS_INFO_check_com cdv || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '.cdv'
    return $?
}
# }}}
VCS_INFO_cvs_detect() { #{{{
    VCS_INFO_check_com svn || return 1
    [[ -d "./CVS" ]] && [[ -r "./CVS/Repository" ]] && return 0
    return 1
}
# }}}
VCS_INFO_darcs_detect() { #{{{
    VCS_INFO_check_com darcs || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '_darcs'
    return $?
}
# }}}
VCS_INFO_git_detect() { #{{{
    if VCS_INFO_check_com git && git rev-parse --is-inside-work-tree &> /dev/null ; then
        vcs_comm[gitdir]="$(git rev-parse --git-dir 2> /dev/null)" || return 1
        if   [[ -d ${vcs_comm[gitdir]}/svn ]]             ; then vcs_comm[overwrite_name]='git-svn'
        elif [[ -d ${vcs_comm[gitdir]}/refs/remotes/p4 ]] ; then vcs_comm[overwrite_name]='git-p4' ; fi
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_hg_detect() { #{{{
    VCS_INFO_check_com hg || return 1
    vcs_comm[detect_need_file]=branch
    VCS_INFO_detect_by_dir '.hg'
    return $?
}
# }}}
VCS_INFO_mtn_detect() { #{{{
    VCS_INFO_check_com mtn || return 1
    vcs_comm[detect_need_file]=revision
    VCS_INFO_detect_by_dir '_MTN'
    return $?
}
# }}}
VCS_INFO_svk_detect() { #{{{
    setopt localoptions noksharrays extendedglob
    local -a info
    local -i fhash
    fhash=0

    VCS_INFO_check_com svk || return 1
    [[ -f ~/.svk/config ]] || return 1

    # This detection function is a bit different from the others.
    # We need to read svk's config file to detect a svk repository
    # in the first place. Therefore, we'll just proceed and read
    # the other information, too. This is more then any of the
    # other detections do but this takes only one file open for
    # svk at most. VCS_INFO_svk_get_data() get simpler, too. :-)
    while IFS= read -r line ; do
        if [[ -n ${vcs_comm[basedir]} ]] ; then
            line=${line## ##}
            [[ ${line} == depotpath:* ]] && vcs_comm[branch]=${line##*/}
            [[ ${line} == revision:* ]] && vcs_comm[revision]=${line##*[[:space:]]##}
            [[ -n ${vcs_comm[branch]} ]] && [[ -n ${vcs_comm[revision]} ]] && break
            continue
        fi
        (( fhash > 0 )) && [[ ${line} == '  '[^[:space:]]*:* ]] && break
        [[ ${line} == '  hash:'* ]] && fhash=1 && continue
        (( fhash == 0 )) && continue
        [[ ${PWD}/ == ${${line## ##}%:*}/* ]] && vcs_comm[basedir]=${${line## ##}%:*}
    done < ~/.svk/config

    [[ -n ${vcs_comm[basedir]} ]]  && \
    [[ -n ${vcs_comm[branch]} ]]   && \
    [[ -n ${vcs_comm[revision]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_svn_detect() { #{{{
    VCS_INFO_check_com svn || return 1
    [[ -d ".svn" ]] && return 0
    return 1
}
# }}}
VCS_INFO_tla_detect() { #{{{
    VCS_INFO_check_com tla || return 1
    vcs_comm[basedir]="$(tla tree-root 2> /dev/null)" && return 0
    return 1
}
# }}}
# public API
vcs_info_printsys () { # {{{
    vcs_info print_systems_
}
# }}}
vcs_info_lastmsg () { # {{{
    local -i i

    VCS_INFO_maxexports
    for i in {0..$((maxexports - 1))} ; do
        printf '$VCS_INFO_message_%d_: "' $i
        if zstyle -T ':vcs_info:formats:command' use-prompt-escapes ; then
            print -nP ${(P)${:-VCS_INFO_message_${i}_}}
        else
            print -n ${(P)${:-VCS_INFO_message_${i}_}}
        fi
        printf '"\n'
    done
}
# }}}
vcs_info () { # {{{
    local pat
    local -i found
    local -a VCSs disabled dps
    local -x vcs usercontext
    local -ix maxexports
    local -ax msgs
    local -Ax vcs_comm

    vcs="init"
    VCSs=(git hg bzr darcs svk mtn svn cvs cdv tla)
    case $1 in
        (print_systems_)
            zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled
            print -l '# list of supported version control backends:' \
                     '# disabled systems are prefixed by a hash sign (#)'
            for vcs in ${VCSs} ; do
                [[ -n ${(M)disabled:#${vcs}} ]] && printf '#'
                printf '%s\n' ${vcs}
            done
            print -l '# flavours (cannot be used in the disable style; they' \
                     '# are disabled with their master [git-svn -> git]):'   \
                     git-{p4,svn}
            return 0
            ;;
        ('')
            [[ -z ${usercontext} ]] && usercontext=default
            ;;
        (*) [[ -z ${usercontext} ]] && usercontext=$1
            ;;
    esac

    zstyle -T ":vcs_info:${vcs}:${usercontext}" "enable" || {
        [[ -n ${VCS_INFO_message_0_} ]] && VCS_INFO_set --clear
        return 0
    }
    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled

    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable-patterns" dps
    for pat in ${dps} ; do
        if [[ ${PWD} == ${~pat} ]] ; then
            [[ -n ${vcs_info_msg_0_} ]] && VCS_INFO_set --clear
            return 0
        fi
    done

    VCS_INFO_maxexports

    (( found = 0 ))
    for vcs in ${VCSs} ; do
        [[ -n ${(M)disabled:#${vcs}} ]] && continue
        vcs_comm=()
        VCS_INFO_${vcs}_detect && (( found = 1 )) && break
    done

    (( found == 0 )) && {
        VCS_INFO_set --nvcs
        return 0
    }

    VCS_INFO_${vcs}_get_data || {
        VCS_INFO_set --nvcs
        return 1
    }

    VCS_INFO_set
    return 0
}

VCS_INFO_set --nvcs preinit
# }}}

# Change vcs_info formats for the grml prompt. The 2nd format sets up
# $vcs_info_msg_1_ to contain "zsh: repo-name" used to set our screen title.
# TODO: The included vcs_info() version still uses $VCS_INFO_message_N_.
#       That needs to be the use of $VCS_INFO_message_N_ needs to be changed
#       to $vcs_info_msg_N_ as soon as we use the included version.
if [[ "$TERM" == dumb ]] ; then
    zstyle ':vcs_info:*' actionformats "(%s%)-[%b|%a] " "zsh: %r"
    zstyle ':vcs_info:*' formats       "(%s%)-[%b] "    "zsh: %r"
else
    # these are the same, just with a lot of colours:
    zstyle ':vcs_info:*' actionformats "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${YELLOW}|${RED}%a${MAGENTA}]${NO_COLOUR} " \
                                       "zsh: %r"
    zstyle ':vcs_info:*' formats       "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${MAGENTA}]${NO_COLOUR}%} " \
                                       "zsh: %r"
    zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YELLOW}%r"
fi

# }}}

# {{{ set prompt
if zrcautoload promptinit && promptinit 2>/dev/null ; then
    promptinit # people should be able to use their favourite prompt
else
    print 'Notice: no promptinit available :('
fi

setopt prompt_subst

# make sure to use right prompt only when not running a command
is41 && setopt transient_rprompt

# TODO: revise all these NO* variables and especially their documentation
#       in zsh-help() below.
is4 && [[ $NOPRECMD -eq 0 ]] && precmd () {
    [[ $NOPRECMD -gt 0 ]] && return 0
    # update VCS information
    vcs_info

    if [[ $TERM == screen* ]] ; then
        if [[ -n ${VCS_INFO_message_1_} ]] ; then
            print -nP "\ek${VCS_INFO_message_1_}\e\\"
        else
            print -nP "\ekzsh\e\\"
        fi
    fi
    # just use DONTSETRPROMPT=1 to be able to overwrite RPROMPT
    if [[ $DONTSETRPROMPT -eq 0 ]] ; then
        if [[ $BATTERY -gt 0 ]] ; then
            # update battery (dropped into $PERCENT) information
            battery
            RPROMPT="%(?..:() ${PERCENT}"
        else
            RPROMPT="%(?..:() "
        fi
    fi
    # adjust title of xterm
    # see http://www.faqs.org/docs/Linux-mini/Xterm-Title.html
    [[ ${NOTITLE} -gt 0 ]] && return 0
    case $TERM in
        (xterm*|rxvt*)
            print -Pn "\e]0;%n@%m: %~\a"
            ;;
    esac
}

# preexec() => a function running before every command
is4 && [[ $NOPRECMD -eq 0 ]] && \
preexec () {
    [[ $NOPRECMD -gt 0 ]] && return 0
# set hostname if not running on host with name 'grml'
    if [[ -n "$HOSTNAME" ]] && [[ "$HOSTNAME" != $(hostname) ]] ; then
       NAME="@$HOSTNAME"
    fi
# get the name of the program currently running and hostname of local machine
# set screen window title if running in a screen
    if [[ "$TERM" == screen* ]] ; then
        # local CMD=${1[(wr)^(*=*|sudo|ssh|-*)]}       # don't use hostname
        local CMD="${1[(wr)^(*=*|sudo|ssh|-*)]}$NAME" # use hostname
        echo -ne "\ek$CMD\e\\"
    fi
# adjust title of xterm
    [[ ${NOTITLE} -gt 0 ]] && return 0
    case $TERM in
        (xterm*|rxvt)
            print -Pn "\e]0;%n@%m: $1\a"
            ;;
    esac
}

EXITCODE="%(?..%?%1v )"
PS2='\`%_> '      # secondary prompt, printed when the shell needs more information to complete a command.
PS3='?# '         # selection prompt used within a select loop.
PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace). default: '+%N:%i>'

# set variable debian_chroot if running in a chroot with /etc/debian_chroot
if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# don't use colors on dumb terminals (like emacs):
if [[ "$TERM" == dumb ]] ; then
    PROMPT="${EXITCODE}${debian_chroot:+($debian_chroot)}%n@%m %40<...<%B%~%b%<< "'${VCS_INFO_message_0_}'"%# "
else
    # only if $GRMLPROMPT is set (e.g. via 'GRMLPROMPT=1 zsh') use the extended prompt
    # set variable identifying the chroot you work in (used in the prompt below)
    if [[ $GRMLPROMPT -gt 0 ]] ; then
        PROMPT="${RED}${EXITCODE}${CYAN}[%j running job(s)] ${GREEN}{history#%!} ${RED}%(3L.+.) ${BLUE}%* %D
${BLUE}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< %# "
    else
        # This assembles the primary prompt string
        if (( EUID != 0 )); then
            PROMPT="${RED}${EXITCODE}${WHITE}${debian_chroot:+($debian_chroot)}${BLUE}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< "'${VCS_INFO_message_0_}'"%# "
        else
            PROMPT="${BLUE}${EXITCODE}${WHITE}${debian_chroot:+($debian_chroot)}${RED}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< "'${VCS_INFO_message_0_}'"%# "
        fi
    fi
fi

# if we are inside a grml-chroot set a specific prompt theme
if [[ -n "$GRML_CHROOT" ]] ; then
    PROMPT="%{$fg[red]%}(CHROOT) %{$fg_bold[red]%}%n%{$fg_no_bold[white]%}@%m %40<...<%B%~%b%<< %\# "
fi
# }}}

# {{{ 'hash' some often used directories
#d# start
hash -d deb=/var/cache/apt/archives
hash -d doc=/usr/share/doc
hash -d linux=/lib/modules/$(command uname -r)/build/
hash -d log=/var/log
hash -d slog=/var/log/syslog
hash -d src=/usr/src
hash -d templ=/usr/share/doc/grml-templates
hash -d tt=/usr/share/doc/texttools-doc
hash -d www=/var/www
#d# end
# }}}

# {{{ some aliases
if check_com -c screen ; then
    if [[ $UID -eq 0 ]] ; then
        [[ -r /etc/grml/screenrc ]] && alias screen="${commands[screen]} -c /etc/grml/screenrc"
    elif [[ -r $HOME/.screenrc ]] ; then
        alias screen="${commands[screen]} -c $HOME/.screenrc"
    else
        [[ -r /etc/grml/screenrc_grml ]] && alias screen="${commands[screen]} -c /etc/grml/screenrc_grml"
    fi
fi

# do we have GNU ls with color-support?
if ls --help 2>/dev/null | grep -- --color= >/dev/null && [[ "$TERM" != dumb ]] ; then
    #a1# execute \kbd{@a@}:\quad ls with colors
    alias ls='ls -b -CF --color=auto'
    #a1# execute \kbd{@a@}:\quad list all files, with colors
    alias la='ls -la --color=auto'
    #a1# long colored list, without dotfiles (@a@)
    alias ll='ls -l --color=auto'
    #a1# long colored list, human readable sizes (@a@)
    alias lh='ls -hAl --color=auto'
    #a1# List files, append qualifier to filenames \\&\quad(\kbd{/} for directories, \kbd{@} for symlinks ...)
    alias l='ls -lF --color=auto'
else
    alias ls='ls -b -CF'
    alias la='ls -la'
    alias ll='ls -l'
    alias lh='ls -hAl'
    alias l='ls -lF'
fi

alias nano='nano -w'
alias mdstat='cat /proc/mdstat'
alias ...='cd ../../'

# generate alias named "$KERNELVERSION-reboot" so you can use boot with kexec:
if [[ -x /sbin/kexec ]] && [[ -r /proc/cmdline ]] ; then
    alias "$(uname -r)-reboot"="kexec -l --initrd=/boot/initrd.img-"$(uname -r)" --command-line=\"$(cat /proc/cmdline)\" /boot/vmlinuz-"$(uname -r)""
fi

alias cp='nocorrect cp'         # no spelling correction on cp
alias mkdir='nocorrect mkdir'   # no spelling correction on mkdir
alias mv='nocorrect mv'         # no spelling correction on mv
alias rm='nocorrect rm'         # no spelling correction on rm

#a1# Execute \kbd{rmdir}
alias rd='rmdir'
#a1# Execute \kbd{rmdir}
alias md='mkdir'

# see http://www.cl.cam.ac.uk/~mgk25/unicode.html#term for details
alias term2iso="echo 'Setting terminal to iso mode' ; print -n '\e%@'"
alias term2utf="echo 'Setting terminal to utf-8 mode'; print -n '\e%G'"

# screen alias
alias scr="screen -U -xRR"
alias banner="banner -w 64"
alias makepatch="diff -Nur"

# make sure it is not assigned yet
[[ $(whence -w utf2iso &>/dev/null) == 'utf2iso: alias' ]] && unalias utf2iso

utf2iso() {
    if isutfenv ; then
        for ENV in $(env | command grep -i '.utf') ; do
            eval export "$(echo $ENV | sed 's/UTF-8/iso885915/ ; s/utf8/iso885915/')"
        done
    fi
}

# make sure it is not assigned yet
[[ $(whence -w iso2utf &>/dev/null) == 'iso2utf: alias' ]] && unalias iso2utf
iso2utf() {
    if ! isutfenv ; then
        for ENV in $(env | command grep -i '\.iso') ; do
            eval export "$(echo $ENV | sed 's/iso.*/UTF-8/ ; s/ISO.*/UTF-8/')"
        done
    fi
}

# set up software synthesizer via speakup
swspeak() {
    if [ -x /usr/sbin/swspeak-setup ] ; then
       setopt singlelinezle
       unsetopt prompt_cr
       export PS1="%m%# "
       /usr/sbin/swspeak-setup $@
     else # old version:
        aumix -w 90 -v 90 -p 90 -m 90
        if ! [[ -r /dev/softsynth ]] ; then
            flite -o play -t "Sorry, software synthesizer not available. Did you boot with swspeak bootoption?"
            return 1
        else
           setopt singlelinezle
           unsetopt prompt_cr
           export PS1="%m%# "
            nice -n -20 speechd-up
            sleep 2
            flite -o play -t "Finished setting up software synthesizer"
        fi
     fi
}

# I like clean prompt, so provide simple way to get that
check_com 0 || alias 0='return 0'

# for really lazy people like mika:
check_com S &>/dev/null || alias S='screen'
check_com s &>/dev/null || alias s='ssh'

# get top 10 shell commands:
alias top10='print -l ? ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

# truecrypt; use e.g. via 'truec /dev/ice /mnt/ice' or 'truec -i'
if check_com -c truecrypt ; then
    if isutfenv ; then
        alias truec='truecrypt --mount-options "rw,sync,dirsync,users,uid=1000,gid=users,umask=077,utf8" '
    else
        alias truec='truecrypt --mount-options "rw,sync,dirsync,users,uid=1000,gid=users,umask=077" '
    fi
fi

#f1# Hints for the use of zsh on grml
zsh-help() {
    print "$bg[white]$fg[black]
zsh-help - hints for use of zsh on grml
=======================================$reset_color"

    print '
Main configuration of zsh happens in /etc/zsh/zshrc.
That file is part of the package grml-etc-core, if you want to
use them on a non-grml-system just get the tar.gz from
http://deb.grml.org/ or (preferably) get it from the git repository:

  http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc

This version of grml'\''s zsh setup does not use skel/.zshrc anymore.
The file is still there, but it is empty for backwards compatibility.

For your own changes use these two files:
    $HOME/.zshrc.pre
    $HOME/.zshrc.local

The former is sourced very early in our zshrc, the latter is sourced
very lately.

System wide configuration without touching configuration files of grml
can take place in /etc/zsh/zshrc.local.

Normally, the root user (EUID == 0) does not get the whole grml setup.
If you want to force the whole setup for that user, too, set
GRML_ALWAYS_LOAD_ALL=1 in .zshrc.pre in root'\''s home directory.

For information regarding zsh start at http://grml.org/zsh/

Take a look at grml'\''s zsh refcard:
% xpdf =(zcat /usr/share/doc/grml-docs/zsh/grml-zsh-refcard.pdf.gz)

Check out the main zsh refcard:
% '$BROWSER' http://www.bash2zsh.com/zsh_refcard/refcard.pdf

And of course visit the zsh-lovers:
% man zsh-lovers

You can adjust some options through environment variables when
invoking zsh without having to edit configuration files.
Basically meant for bash users who are not used to the power of
the zsh yet. :)

  "NOCOR=1    zsh" => deactivate automatic correction
  "NOMENU=1   zsh" => do not use auto menu completion (note: use ctrl-d for completion instead!)
  "NOPRECMD=1 zsh" => disable the precmd + preexec commands (set GNU screen title)
  "NOTITLE=1  zsh" => disable setting the title of xterms without disabling
                      preexec() and precmd() completely
  "BATTERY=1  zsh" => activate battery status (via acpi) on right side of prompt

A value greater than 0 is enables a feature; a value equal to zero
disables it. If you like one or the other of these settings, you can
add them to ~/.zshrc.pre to ensure they are set when sourcing grml'\''s
zshrc.'

    print "
$bg[white]$fg[black]
Please report wishes + bugs to the grml-team: http://grml.org/bugs/
Enjoy your grml system with the zsh!$reset_color"
}

# debian stuff
if [[ -r /etc/debian_version ]] ; then
    #a3# Execute \kbd{apt-cache search}
    alias acs='apt-cache search'
    #a3# Execute \kbd{apt-cache show}
    alias acsh='apt-cache show'
    #a3# Execute \kbd{apt-cache policy}
    alias acp='apt-cache policy'
    #a3# Execute \kbd{apt-get dist-upgrade}
    salias adg="apt-get dist-upgrade"
    #a3# Execute \kbd{apt-get install}
    salias agi="apt-get install"
    #a3# Execute \kbd{aptitude install}
    salias ati="aptitude install"
    #a3# Execute \kbd{apt-get upgrade}
    salias ag="apt-get upgrade"
    #a3# Execute \kbd{apt-get update}
    salias au="apt-get update"
    #a3# Execute \kbd{aptitude update ; aptitude safe-upgrade}
    salias -a up="aptitude update ; aptitude safe-upgrade"
    #a3# Execute \kbd{dpkg-buildpackage}
    alias dbp='dpkg-buildpackage'
    #a3# Execute \kbd{grep-excuses}
    alias ge='grep-excuses'

    # debian upgrade
    #f3# Execute \kbd{apt-get update \&\& }\\&\quad \kbd{apt-get dist-upgrade}
    upgrade() {
        if [[ -z "$1" ]] ; then
            $SUDO apt-get update
            $SUDO apt-get -u upgrade
        else
            ssh $1 $SUDO apt-get update
            # ask before the upgrade
            local dummy
            ssh $1 $SUDO apt-get --no-act upgrade
            echo -n 'Process the upgrade?'
            read -q dummy
            if [[ $dummy == "y" ]] ; then
                ssh $1 $SUDO apt-get -u upgrade --yes
            fi
        fi
    }

    # get a root shell as normal user in live-cd mode:
    if isgrmlcd && [[ $UID -ne 0 ]] ; then
       alias su="sudo su"
     fi

    #a1# Take a look at the syslog: \kbd{\$PAGER /var/log/syslog}
    alias llog="$PAGER /var/log/syslog"     # take a look at the syslog
    #a1# Take a look at the syslog: \kbd{tail -f /var/log/syslog}
    alias tlog="tail -f /var/log/syslog"    # follow the syslog
fi

# sort installed Debian-packages by size
if check_com -c grep-status ; then
    #a3# List installed Debian-packages sorted by size
    alias debs-by-size='grep-status -FStatus -sInstalled-Size,Package -n "install ok installed" | paste -sd "  \n" | sort -rn'
fi

# if cdrecord is a symlink (to wodim) or isn't present at all warn:
if [[ -L /usr/bin/cdrecord ]] || ! check_com -c cdrecord ; then
    if check_com -c wodim ; then
        alias cdrecord="echo 'cdrecord is not provided under its original name by Debian anymore.
See #377109 in the BTS of Debian for more details.

Please use the wodim binary instead' ; return 1"
    fi
fi

# get_tw_cli has been renamed into get_3ware
if check_com -c get_3ware ; then
    get_tw_cli() {
        echo 'Warning: get_tw_cli has been renamed into get_3ware. Invoking get_3ware for you.'>&2
        get_3ware
    }
fi

# I hate lacking backward compatibility, so provide an alternative therefore
if ! check_com -c apache2-ssl-certificate ; then

    apache2-ssl-certificate() {

    print 'Debian does not ship apache2-ssl-certificate anymore (see #398520). :('
    print 'You might want to take a look at Debian the package ssl-cert as well.'
    print 'To generate a certificate for use with apache2 follow the instructions:'

    echo '

export RANDFILE=/dev/random
mkdir /etc/apache2/ssl/
openssl req $@ -new -x509 -days 365 -nodes -out /etc/apache2/ssl/apache.pem -keyout /etc/apache2/ssl/apache.pem
chmod 600 /etc/apache2/ssl/apache.pem

Run "grml-tips ssl-certificate" if you need further instructions.
'
    }
fi
# }}}

# {{{ Use hard limits, except for a smaller stack and no core dumps
unlimit
is425 && limit stack 8192
isgrmlcd && limit core 0 # important for a live-cd-system
limit -s
# }}}

# {{{ completion system

# called later (via is4 && grmlcomp)
# note: use 'zstyle' for getting current settings
#         press ^Xh (control-x h) for getting tags in context; ^X? (control-x ?) to run complete_debug with trace output
grmlcomp() {
    # TODO: This could use some additional information

    # allow one error for every three characters typed in approximate completer
    zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

    # don't complete backup files as executables
    zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

    # start menu completion only if it could find no unambiguous initial string
    zstyle ':completion:*:correct:*'       insert-unambiguous true
    zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
    zstyle ':completion:*:correct:*'       original true

    # activate color-completion
    zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

    # format on completion
    zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

    # complete 'cd -<tab>' with menu
    zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

    # insert all expansions for expand completer
    zstyle ':completion:*:expand:*'        tag-order all-expansions
    zstyle ':completion:*:history-words'   list false

    # activate menu
    zstyle ':completion:*:history-words'   menu yes

    # ignore duplicate entries
    zstyle ':completion:*:history-words'   remove-all-dups yes
    zstyle ':completion:*:history-words'   stop yes

    # match uppercase from lowercase
    zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

    # separate matches into groups
    zstyle ':completion:*:matches'         group 'yes'
    zstyle ':completion:*'                 group-name ''

    if [[ "$NOMENU" -eq 0 ]] ; then
        # if there are more than 5 options allow selecting from a menu
        zstyle ':completion:*'               menu select=5
    else
        # don't use any menus at all
        setopt no_auto_menu
    fi

    zstyle ':completion:*:messages'        format '%d'
    zstyle ':completion:*:options'         auto-description '%d'

    # describe options in full
    zstyle ':completion:*:options'         description 'yes'

    # on processes completion complete all user processes
    zstyle ':completion:*:processes'       command 'ps -au$USER'

    # offer indexes before parameters in subscripts
    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

    # provide verbose completion information
    zstyle ':completion:*'                 verbose true

    # recent (as of Dec 2007) zsh versions are able to provide descriptions
    # for commands (read: 1st word in the line) that it will list for the user
    # to choose from. The following disables that, because it's not exactly fast.
    zstyle ':completion:*:-command-:*:'    verbose false

    # set format for warnings
    zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

    # define files to ignore for zcompile
    zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
    zstyle ':completion:correct:'          prompt 'correct to: %e'

    # Ignore completion functions for commands you don't have:
    zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

    # Provide more processes in completion of programs like killall:
    zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

    # complete manual by their section
    zstyle ':completion:*:manuals'    separate-sections true
    zstyle ':completion:*:manuals.*'  insert-sections   true
    zstyle ':completion:*:man:*'      menu yes select

    # provide .. as a completion
    zstyle ':completion:*' special-dirs ..

    # run rehash on completion so new installed program are found automatically:
    _force_rehash() {
        (( CURRENT == 1 )) && rehash
        return 1
    }

    ## correction
    # some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
    if [[ "$NOCOR" -gt 0 ]] ; then
        zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored
        setopt nocorrect
    else
        # try to be smart about when to use what completer...
        setopt correct
        zstyle -e ':completion:*' completer '
            if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
                _last_try="$HISTNO$BUFFER$CURSOR"
                reply=(_complete _match _ignored _prefix _files)
            else
                if [[ $words[1] == (rm|mv) ]] ; then
                    reply=(_complete _files)
                else
                    reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
                fi
            fi'
    fi

    # command for process lists, the local web server details and host completion
    zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

    # caching
    [[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
                            zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

    # host completion /* add brackets as vim can't parse zsh's complex cmdlines 8-) {{{ */
    if is42 ; then
        [[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
        [[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
    else
        _ssh_hosts=()
        _etc_hosts=()
    fi
    hosts=(
        $(hostname)
        "$_ssh_hosts[@]"
        "$_etc_hosts[@]"
        grml.org
        localhost
    )
    zstyle ':completion:*:hosts' hosts $hosts
    # TODO: so, why is this here?
    #  zstyle '*' hosts $hosts

    # use generic completion system for programs not yet defined; (_gnu_generic works
    # with commands that provide a --help option with "standard" gnu-like output.)
    compdef _gnu_generic tail head feh cp mv df stow uname ipacsum fetchipac

    # see upgrade function in this file
    compdef _hosts upgrade
}
# }}}

# {{{ grmlstuff
grmlstuff() {
# people should use 'grml-x'!
    startx() {
        if [[ -e /etc/X11/xorg.conf ]] ; then
            [[ -x /usr/bin/startx ]] && /usr/bin/startx "$@" || /usr/X11R6/bin/startx "$@"
        else
            echo "Please use the script \"grml-x\" for starting the X Window System
because there does not exist /etc/X11/xorg.conf yet.
If you want to use startx anyway please call \"/usr/bin/startx\"."
            return -1
        fi
    }

    xinit() {
        if [[ -e /etc/X11/xorg.conf ]] ; then
            [[ -x /usr/bin/xinit ]] && /usr/bin/xinit || /usr/X11R6/bin/xinit
        else
            echo "Please use the script \"grml-x\" for starting the X Window System.
because there does not exist /etc/X11/xorg.conf yet.
If you want to use xinit anyway please call \"/usr/bin/xinit\"."
            return -1
        fi
    }

    if check_com -c 915resolution ; then
        alias 855resolution='echo -e "Please use 915resolution as resolution modify tool for Intel graphic chipset."; return -1'
    fi

    #a1# Output version of running grml
    alias grml-version='cat /etc/grml_version'

    if check_com -c rebuildfstab ; then
        #a1# Rebuild /etc/fstab
        alias grml-rebuildfstab='rebuildfstab -v -r -config'
    fi

    if check_com -c grml-debootstrap ; then
        alias debian2hd='print "Installing debian to harddisk is possible via using grml-debootstrap." ; return 1'
    fi
}
# }}}

# {{{ now run the functions
isgrml && checkhome
is4    && isgrml    && grmlstuff
is4    && grmlcomp
# }}}

# {{{ keephack
is4 && xsource "/etc/zsh/keephack"
# }}}

# {{{ wonderful idea of using "e" glob qualifier by Peter Stephenson
# You use it as follows:
# $ NTREF=/reference/file
# $ ls -l *(e:nt:)
# This lists all the files in the current directory newer than the reference file.
# You can also specify the reference file inline; note quotes:
# $ ls -l *(e:'nt ~/.zshenv':)
is4 && nt() {
    if [[ -n $1 ]] ; then
        local NTREF=${~1}
    fi
    [[ $REPLY -nt $NTREF ]]
}
# }}}

# shell functions {{{

#f1# Provide csh compatibility
setenv()  { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }  # csh compatibility

#f1# Reload an autoloadable function
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }

#f1# Reload zsh setup
reload() {
    if [[ "$#*" -eq 0 ]] ; then
        [[ -r ~/.zshrc ]] && . ~/.zshrc
    else
        local fn
        for fn in "$@"; do
            unfunction $fn
            autoload -U $fn
        done
    fi
}
compdef _functions reload freload

#f1# List symlinks in detail (more detailed version of 'readlink -f' and 'whence -s')
sll() {
    [[ -z "$1" ]] && printf 'Usage: %s <file(s)>\n' "$0" && return 1
    for i in "$@" ; do
        file=$i
        while [[ -h "$file" ]] ; do
            ls -l $file
            file=$(readlink "$file")
        done
    done
}

# fast manual access
if check_com qma ; then
    #f1# View the zsh manual
    manzsh()  { qma zshall "$1" }
    compdef _man qma
else
    manzsh()  { /usr/bin/man zshall |  vim -c "se ft=man| se hlsearch" +/"$1" - ; }
fi

if check_com -c $PAGER ; then
    #f1# View Debian's changelog of a given package
    dchange() {
        if [[ -r /usr/share/doc/${1}/changelog.Debian.gz ]] ; then
            $PAGER /usr/share/doc/${1}/changelog.Debian.gz
        elif [[ -r /usr/share/doc/${1}/changelog.gz ]] ; then
            $PAGER /usr/share/doc/${1}/changelog.gz
        else
            if check_com -c aptitude ; then
                echo "No changelog for package $1 found, using aptitude to retrieve it."
                if isgrml ; then
                    aptitude -t unstable changelog ${1}
                else
                    aptitude changelog ${1}
                fi
            else
                echo "No changelog for package $1 found, sorry."
                return 1
            fi
        fi
    }
    _dchange() { _files -W /usr/share/doc -/ }
    compdef _dchange dchange

    #f1# View Debian's NEWS of a given package
    dnews() {
        if [[ -r /usr/share/doc/${1}/NEWS.Debian.gz ]] ; then
            $PAGER /usr/share/doc/${1}/NEWS.Debian.gz
        else
            if [[ -r /usr/share/doc/${1}/NEWS.gz ]] ; then
                $PAGER /usr/share/doc/${1}/NEWS.gz
            else
                echo "No NEWS file for package $1 found, sorry."
                return 1
            fi
        fi
    }
    _dnews() { _files -W /usr/share/doc -/ }
    compdef _dnews dnews

    #f1# View upstream's changelog of a given package
    uchange() {
        if [[ -r /usr/share/doc/${1}/changelog.gz ]] ; then
            $PAGER /usr/share/doc/${1}/changelog.gz
        else
            echo "No changelog for package $1 found, sorry."
            return 1
        fi
    }
    _uchange() { _files -W /usr/share/doc -/ }
    compdef _uchange uchange
fi

# zsh profiling
profile() {
    ZSH_PROFILE_RC=1 $SHELL "$@"
}

#f1# Edit an alias via zle
edalias() {
    [[ -z "$1" ]] && { echo "Usage: edalias <alias_to_edit>" ; return 1 } || vared aliases'[$1]' ;
}
compdef _aliases edalias

#f1# Edit a function via zle
edfunc() {
    [[ -z "$1" ]] && { echo "Usage: edfun <function_to_edit>" ; return 1 } || zed -f "$1" ;
}
compdef _functions edfunc

# use it e.g. via 'Restart apache2'
#m# f6 Start() \kbd{/etc/init.d/\em{process}}\quad\kbd{start}
#m# f6 Restart() \kbd{/etc/init.d/\em{process}}\quad\kbd{restart}
#m# f6 Stop() \kbd{/etc/init.d/\em{process}}\quad\kbd{stop}
#m# f6 Reload() \kbd{/etc/init.d/\em{process}}\quad\kbd{reload}
#m# f6 Force-Reload() \kbd{/etc/init.d/\em{process}}\quad\kbd{force-reload}
if [[ -d /etc/init.d || -d /etc/service ]] ; then
    __start_stop() {
        local action_="${1:l}"  # e.g Start/Stop/Restart
        local service_="$2"
        local param_="$3"

        local service_target_="$(readlink /etc/init.d/$service_)"
        if [[ $service_target_ == "/usr/bin/sv" ]]; then
            # runit
            case "${action_}" in
                start) if [[ ! -e /etc/service/$service_ ]]; then
                           $SUDO ln -s "/etc/sv/$service_" "/etc/service/"
                       else
                           $SUDO "/etc/init.d/$service_" "${action_}" "$param_"
                       fi ;;
                # there is no reload in runits sysv emulation
                reload) $SUDO "/etc/init.d/$service_" "force-reload" "$param_" ;;
                *) $SUDO "/etc/init.d/$service_" "${action_}" "$param_" ;;
            esac
        else
            # sysvinit
            $SUDO "/etc/init.d/$service_" "${action_}" "$param_"
        fi
    }

    for i in Start Restart Stop Force-Reload Reload ; do
        eval "$i() { __start_stop $i \"\$1\" \"\$2\" ; }"
    done
fi

#f1# Provides useful information on globbing
H-Glob() {
    echo -e "
    /      directories
    .      plain files
    @      symbolic links
    =      sockets
    p      named pipes (FIFOs)
    *      executable plain files (0100)
    %      device files (character or block special)
    %b     block special files
    %c     character special files
    r      owner-readable files (0400)
    w      owner-writable files (0200)
    x      owner-executable files (0100)
    A      group-readable files (0040)
    I      group-writable files (0020)
    E      group-executable files (0010)
    R      world-readable files (0004)
    W      world-writable files (0002)
    X      world-executable files (0001)
    s      setuid files (04000)
    S      setgid files (02000)
    t      files with the sticky bit (01000)

  print *(m-1)          # Files modified up to a day ago
  print *(a1)           # Files accessed a day ago
  print *(@)            # Just symlinks
  print *(Lk+50)        # Files bigger than 50 kilobytes
  print *(Lk-50)        # Files smaller than 50 kilobytes
  print **/*.c          # All *.c files recursively starting in \$PWD
  print **/*.c~file.c   # Same as above, but excluding 'file.c'
  print (foo|bar).*     # Files starting with 'foo' or 'bar'
  print *~*.*           # All Files that do not contain a dot
  chmod 644 *(.^x)      # make all plain non-executable files publically readable
  print -l *(.c|.h)     # Lists *.c and *.h
  print **/*(g:users:)  # Recursively match all files that are owned by group 'users'
  echo /proc/*/cwd(:h:t:s/self//) # Analogous to >ps ax | awk '{print $1}'<"
}
alias help-zshglob=H-Glob

check_com -c qma && alias ?='qma zshall'

# grep for running process, like: 'any vim'
any() {
    if [[ -z "$1" ]] ; then
        echo "any - grep for process(es) by keyword" >&2
        echo "Usage: any <keyword>" >&2 ; return 1
    else
        local STRING=$1
        local LENGTH=$(expr length $STRING)
        local FIRSCHAR=$(echo $(expr substr $STRING 1 1))
        local REST=$(echo $(expr substr $STRING 2 $LENGTH))
        ps xauwww| grep "[$FIRSCHAR]$REST"
    fi
}

# After resuming from suspend, system is paging heavily, leading to very bad interactivity.
# taken from $LINUX-KERNELSOURCE/Documentation/power/swsusp.txt
[[ -r /proc/1/maps ]] && \
deswap() {
    print 'Reading /proc/[0-9]*/maps and sending output to /dev/null, this might take a while.'
    cat $(sed -ne 's:.* /:/:p' /proc/[0-9]*/maps | sort -u | grep -v '^/dev/')  > /dev/null
    print 'Finished, running "swapoff -a; swapon -a" may also be useful.'
}

# print hex value of a number
hex() {
    [[ -n "$1" ]] && printf "%x\n" $1 || { print 'Usage: hex <number-to-convert>' ; return 1 }
}

# calculate (or eval at all ;-)) with perl => p[erl-]eval
# hint: also take a look at zcalc -> 'autoload zcalc' -> 'man zshmodules | less -p MATHFUNC'
peval() {
    [[ -n "$1" ]] && CALC="$*" || print "Usage: calc [expression]"
    perl -e "print eval($CALC),\"\n\";"
}
functions peval &>/dev/null && alias calc=peval

# brltty seems to have problems with utf8 environment and/or font Uni3-Terminus16 under
# certain circumstances, so work around it, no matter which environment we have
brltty() {
    if [[ -z "$DISPLAY" ]] ; then
        consolechars -f /usr/share/consolefonts/default8x16.psf.gz
        command brltty "$@"
    else
        command brltty "$@"
    fi
}

# just press 'asdf' keys to toggle between dvorak and us keyboard layout
aoeu() {
    echo -n 'Switching to us keyboard layout: '
    [[ -z "$DISPLAY" ]] && $SUDO loadkeys us &>/dev/null || setxkbmap us &>/dev/null
    echo 'Done'
}
asdf() {
    echo -n 'Switching to dvorak keyboard layout: '
    [[ -z "$DISPLAY" ]] && $SUDO loadkeys dvorak &>/dev/null || setxkbmap dvorak &>/dev/null
    echo 'Done'
}
# just press 'asdf' key to toggle from neon layout to us keyboard layout
uiae() {
    echo -n 'Switching to us keyboard layout: '
    setxkbmap us && echo 'Done' || echo 'Failed'
}

# set up an ipv6 tunnel
ipv6-tunnel() {
    case $1 in
        start)
            if ifconfig sit1 2>/dev/null | grep -q 'inet6 addr: 2002:.*:1::1' ; then
                print 'ipv6 tunnel already set up, nothing to be done.'
                print 'execute: "ifconfig sit1 down ; ifconfig sit0 down" to remove ipv6-tunnel.' ; return 1
            else
                [[ -n "$PUBLIC_IP" ]] || \
                    local PUBLIC_IP=$(ifconfig $(route -n | awk '/^0\.0\.0\.0/{print $8; exit}') | \
                                      awk '/inet addr:/ {print $2}' | tr -d 'addr:')

                [[ -n "$PUBLIC_IP" ]] || { print 'No $PUBLIC_IP set and could not determine default one.' ; return 1 }
                local IPV6ADDR=$(printf "2002:%02x%02x:%02x%02x:1::1" $(print ${PUBLIC_IP//./ }))
                print -n "Setting up ipv6 tunnel $IPV6ADDR via ${PUBLIC_IP}: "
                ifconfig sit0 tunnel ::192.88.99.1 up
                ifconfig sit1 add "$IPV6ADDR" && print done || print failed
            fi
            ;;
        status)
            if ifconfig sit1 2>/dev/null | grep -q 'inet6 addr: 2002:.*:1::1' ; then
                print 'ipv6 tunnel available' ; return 0
            else
                print 'ipv6 tunnel not available' ; return 1
            fi
            ;;
        stop)
            if ifconfig sit1 2>/dev/null | grep -q 'inet6 addr: 2002:.*:1::1' ; then
                print -n 'Stopping ipv6 tunnel (sit0 + sit1): '
                ifconfig sit1 down ; ifconfig sit0 down && print done || print failed
            else
                print 'No ipv6 tunnel found, nothing to be done.' ; return 1
            fi
            ;;
        *)
            print "Usage: ipv6-tunnel [start|stop|status]">&2 ; return 1
            ;;
    esac
}

# run dhclient for wireless device
iwclient() {
    salias dhclient "$(wavemon -d | awk '/device/{print $2}')"
}

# spawn a minimally set up ksh - useful if you want to umount /usr/.
minimal-shell() {
    exec env -i ENV="/etc/minimal-shellrc" HOME="$HOME" TERM="$TERM" ksh
}

# make a backup of a file
bk() {
    cp -a "$1" "${1}_$(date --iso-8601=seconds)"
}

#f1# grep for patterns in grml's zsh setup
zg() {
#{{{
    LANG=C perl -e '

sub usage {
    print "usage: zg -[anr] <pattern>\n";
    print " Search for patterns in grml'\''s zshrc.\n";
    print " zg takes no or exactly one option plus a non empty pattern.\n\n";
    print "   options:\n";
    print "     --  no options (use if your pattern starts in with a dash.\n";
    print "     -a  search for the pattern in all code regions\n";
    print "     -n  search for the pattern in non-root code only\n";
    print "     -r  search in code for everyone (also root) only\n\n";
    print "   The default is -a for non-root users and -r for root.\n\n";
    print " If you installed the zshrc to a non-default locations (ie *NOT*\n";
    print " in /etc/zsh/zshrc) do: export GRML_ZSHRC=\$HOME/.zshrc\n";
    print " ...in case you copied the file to that location.\n\n";
    exit 1;
}

if ($ENV{GRML_ZSHRC} ne "") {
    $RC = $ENV{GRML_ZSHRC};
} else {
    $RC = "/etc/zsh/zshrc";
}

usage if ($#ARGV < 0 || $#ARGV > 1);
if ($> == 0) { $mode = "allonly"; }
else { $mode = "all"; }

$opt = $ARGV[0];
if ($opt eq "--")     { shift; }
elsif ($opt eq "-a")  { $mode = "all"; shift; }
elsif ($opt eq "-n")  { $mode = "nonroot"; shift; }
elsif ($opt eq "-r" ) { $mode = "allonly"; shift; }
elsif ($opt =~ m/^-/ || $#ARGV > 0) { usage(); }

$pattern = $ARGV[0];
usage() if ($pattern eq "");

open FH, "<$RC" or die "zg: Could not open $RC: $!\n";
while ($line = <FH>) {
    chomp $line;
    if ($line =~ m/^#:grep:marker:for:mika:/) { $markerfound = 1; next; }
    next if ($mode eq "nonroot" && markerfound == 0);
    break if ($mode eq "allonly" && markerfound == 1);
    print $line, "\n" if ($line =~ /$pattern/);
}
close FH;
exit 0;

    ' -- "$@"
#}}}
    return $?
}

# }}}

# {{{ make sure our environment is clean regarding colors
for color in BLUE RED GREEN CYAN YELLOW MAGENTA WHITE ; unset $color
# }}}

# source another config file if present {{{
xsource "/etc/zsh/zshrc.local"
# }}}

# "persistent history" {{{
# just write important commands you always need to ~/.important_commands
if [[ -r ~/.important_commands ]] ; then
    fc -R ~/.important_commands
fi
# }}}

#:grep:marker:for:mika: :-)
### non-root (EUID != 0) code below
###

if (( GRML_ALWAYS_LOAD_ALL == 0 )) && (( $EUID == 0 )) ; then
    zrclocal
    return 0
fi


# variables {{{

# set terminal property (used e.g. by msgid-chooser)
export COLORTERM="yes"

# set default browser
if [[ -z "$BROWSER" ]] ; then
    if [[ -n "$DISPLAY" ]] ; then
        #v# If X11 is running
        check_com -c firefox && export BROWSER=firefox
    else
        #v# If no X11 is running
        check_com -c elinks && export BROWSER=elinks
    fi
fi

#m# v QTDIR \kbd{/usr/share/qt[34]}\quad [for non-root only]
[[ -d /usr/share/qt3 ]] && export QTDIR=/usr/share/qt3
[[ -d /usr/share/qt4 ]] && export QTDIR=/usr/share/qt4

# support running 'jikes *.java && jamvm HelloWorld' OOTB:
#v# [for non-root only]
[[ -f /usr/share/classpath/glibj.zip ]] && export JIKESPATH=/usr/share/classpath/glibj.zip
# }}}

# aliases {{{

# Xterm resizing-fu.
# Based on http://svn.kitenet.net/trunk/home-full/.zshrc?rev=11710&view=log (by Joey Hess)
alias hide='echo -en "\033]50;nil2\007"'
alias tiny='echo -en "\033]50;-misc-fixed-medium-r-normal-*-*-80-*-*-c-*-iso8859-15\007"'
alias small='echo -en "\033]50;6x10\007"'
alias medium='echo -en "\033]50;-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso8859-15\007"'
alias default='echo -e "\033]50;-misc-fixed-medium-r-normal-*-*-140-*-*-c-*-iso8859-15\007"'
alias large='echo -en "\033]50;-misc-fixed-medium-r-normal-*-*-150-*-*-c-*-iso8859-15\007"'
alias huge='echo -en "\033]50;-misc-fixed-medium-r-normal-*-*-210-*-*-c-*-iso8859-15\007"'
alias smartfont='echo -en "\033]50;-artwiz-smoothansi-*-*-*-*-*-*-*-*-*-*-*-*\007"'
alias semifont='echo -en "\033]50;-misc-fixed-medium-r-semicondensed-*-*-120-*-*-*-*-iso8859-15\007"'

# general
#a2# Execute \kbd{du -sch}
alias da='du -sch'
#a2# Execute \kbd{jobs -l}
alias j='jobs -l'

# compile stuff
#a2# Execute \kbd{./configure}
alias CO="./configure"
#a2# Execute \kbd{./configure --help}
alias CH="./configure --help"

# http://conkeror.mozdev.org/
# TODO: I think this should be removed, as conkeror is not a simple extension anymore
#a2# Run a keyboard driven firefox
alias conkeror='firefox -chrome chrome://conkeror/content'

# arch/tla stuff
if check_com -c tla ; then
    #a2# Execute \kbd{tla what-changed --diffs | less}
    alias tdi='tla what-changed --diffs | less'
    #a2# Execute \kbd{tla-buildpackage}
    alias tbp='tla-buildpackage'
    #a2# Execute \kbd{tla archive-mirror}
    alias tmi='tla archive-mirror'
    #a2# Execute \kbd{tla commit}
    alias tco='tla commit'
    #a2# Execute \kbd{tla star-merge}
    alias tme='tla star-merge'
fi

# listing stuff
#a2# Execute \kbd{ls -lSrah}
alias dir="ls -lSrah"
#a2# Only show dot-directories
alias lad='ls -d .*(/)'                # only show dot-directories
#a2# Only show dot-files
alias lsa='ls -a .*(.)'                # only show dot-files
#a2# Only files with setgid/setuid/sticky flag
alias lss='ls -l *(s,S,t)'             # only files with setgid/setuid/sticky flag
#a2# Only show 1st ten symlinks
alias lsl='ls -l *(@[1,10])'           # only symlinks
#a2# Display only executables
alias lsx='ls -l *(*[1,10])'           # only executables
#a2# Display world-{readable,writable,executable} files
alias lsw='ls -ld *(R,W,X.^ND/)'       # world-{readable,writable,executable} files
#a2# Display the ten biggest files
alias lsbig="ls -flh *(.OL[1,10])"     # display the biggest files
#a2# Only show directories
alias lsd='ls -d *(/)'                 # only show directories
#a2# Only show empty directories
alias lse='ls -d *(/^F)'               # only show empty directories
#a2# Display the ten newest files
alias lsnew="ls -rl *(D.om[1,10])"     # display the newest files
#a2# Display the ten oldest files
alias lsold="ls -rtlh *(D.om[1,10])"   # display the oldest files
#a2# Display the ten smallest files
alias lssmall="ls -Srl *(.oL[1,10])"   # display the smallest files

# chmod
#a2# Execute \kbd{chmod 600}
alias rw-='chmod 600'
#a2# Execute \kbd{chmod 700}
alias rwx='chmod 700'
#m# a2 r-{}- Execute \kbd{chmod 644}
alias r--='chmod 644'
#a2# Execute \kbd{chmod 755}
alias r-x='chmod 755'

# some useful aliases
#a2# Execute \kbd{mkdir -o}
alias md='mkdir -p'

check_com -c ipython && alias ips='ipython -p sh'

# console stuff
#a2# Execute \kbd{mplayer -vo fbdev}
alias cmplayer='mplayer -vo fbdev'
#a2# Execute \kbd{mplayer -vo fbdev -fs -zoom}
alias fbmplayer='mplayer -vo fbdev -fs -zoom'
#a2# Execute \kbd{links2 -driver fb}
alias fblinks='links2 -driver fb'

#a2# ssh with StrictHostKeyChecking=no \\&\quad and UserKnownHostsFile unset
alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias insecscp='scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

# simple webserver
check_com -c python && alias http="python -m SimpleHTTPServer"

# Use 'g' instead of 'git':
check_com g || alias g='git'

# use colors when browsing man pages, but only if not using LESS_TERMCAP_* from /etc/zsh/zshenv:
if [[ -z "$LESS_TERMCAP_md" ]] ; then
    [[ -d ~/.terminfo/ ]] && alias man='TERMINFO=~/.terminfo/ LESS=C TERM=mostlike PAGER=less man'
fi

# check whether Debian's package management (dpkg) is running
if check_com salias ; then
    #a2# Check whether a dpkg instance is currently running
    salias check_dpkg_running="dpkg_running"
fi

# work around non utf8 capable software in utf environment via $LANG and luit
if check_com isutfenv && check_com luit ; then
    if check_com -c mrxvt ; then
        isutfenv && [[ -n "$LANG" ]] && \
            alias mrxvt="LANG=${LANG/(#b)(*)[.@]*/$match[1].iso885915} luit mrxvt"
    fi

    if check_com -c aterm ; then
        isutfenv && [[ -n "$LANG" ]] && \
            alias aterm="LANG=${LANG/(#b)(*)[.@]*/$match[1].iso885915} luit aterm"
    fi

    if check_com -c centericq ; then
        isutfenv && [[ -n "$LANG" ]] && \
            alias centericq="LANG=${LANG/(#b)(*)[.@]*/$match[1].iso885915} luit centericq"
    fi
fi
# }}}

# useful functions {{{

# searching
#f4# Search for newspostings from authors
agoogle() { ${=BROWSER} "http://groups.google.com/groups?as_uauthors=$*" ; }
#f4# Search Debian Bug Tracking System
debbug()  {
    setopt localoptions extendedglob
    if [[ $# -eq 1 ]]; then
        case "$1" in
            ([0-9]##)
            ${=BROWSER} "http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=$1"
            ;;
            (*@*)
            ${=BROWSER} "http://bugs.debian.org/cgi-bin/pkgreport.cgi?submitter=$1"
            ;;
            (*)
            ${=BROWSER} "http://bugs.debian.org/$*"
            ;;
        esac
    else
        print "$0 needs one argument"
        return 1
    fi
}
#f4# Search Debian Bug Tracking System in mbox format
debbugm() { bts show --mbox $1 } # provide bugnummer as "$1"
#f4# Search DMOZ
dmoz()    { ${=BROWSER} http://search.dmoz.org/cgi-bin/search\?search=${1// /_} }
#f4# Search German   Wiktionary
dwicti()  { ${=BROWSER} http://de.wiktionary.org/wiki/${(C)1// /_} }
#f4# Search English  Wiktionary
ewicti()  { ${=BROWSER} http://en.wiktionary.org/wiki/${(C)1// /_} }
#f4# Search Google Groups
ggogle()  { ${=BROWSER} "http://groups.google.com/groups?q=$*" }
#f4# Search Google
google()  { ${=BROWSER} "http://www.google.com/search?&num=100&q=$*" }
#f4# Search Google Groups for MsgID
mggogle() { ${=BROWSER} "http://groups.google.com/groups?selm=$*" }
#f4# Search Netcraft
netcraft(){ ${=BROWSER} "http://toolbar.netcraft.com/site_report?url=$1" }
#f4# Use German Wikipedia's full text search
swiki()   { ${=BROWSER} http://de.wikipedia.org/wiki/Spezial:Search/${(C)1} }
#f4# search \kbd{dict.leo.org}
oleo()    { ${=BROWSER} "http://dict.leo.org/?search=$*" }
#f4# Search German   Wikipedia
wikide()  { ${=BROWSER} http://de.wikipedia.org/wiki/"${(C)*}" }
#f4# Search English  Wikipedia
wikien()  { ${=BROWSER} http://en.wikipedia.org/wiki/"${(C)*}" }
#f4# Search official debs
wodeb()   { ${=BROWSER} "http://packages.debian.org/search?keywords=$1&searchon=contents&suite=${2:=unstable}&section=all" }

#m# f4 gex() Exact search via Google
check_com google && gex () { google "\"[ $1]\" $*" } # exact search at google

# misc
#f5# Backup \kbd{file {\rm to} file\_timestamp}
bk()      { cp -b ${1} ${1}_`date --iso-8601=m` }
#f5# Copied diff
cdiff()   { diff -crd "$*" | egrep -v "^Only in |^Binary files " }
#f5# cd to directoy and list files
cl()      { cd $1 && ls -a }        # cd && ls
#f5# Cvs add
cvsa()    { cvs add $* && cvs com -m 'initial checkin' $* }
#f5# Cvs diff
cvsd()    { cvs diff -N $* |& $PAGER }
#f5# Cvs log
cvsl()    { cvs log $* |& $PAGER }
#f5# Cvs update
cvsq()    { cvs -nq update }
#f5# Rcs2log
cvsr()    { rcs2log $* | $PAGER }
#f5# Cvs status
cvss()    { cvs status -v $* }
#f5# Disassemble source files using gcc and as
disassemble(){ gcc -pipe -S -o - -O -g $* | as -aldh -o /dev/null }
#f5# Firefox remote control - open given URL
fir()     { firefox -a firefox -remote "openURL($1)" }
#f5# Create Directoy and \kbd{cd} to it
mcd()     { mkdir -p "$@"; cd "$@" } # mkdir && cd
#f5# Unified diff to timestamped outputfile
mdiff()   { diff -udrP "$1" "$2" > diff.`date "+%Y-%m-%d"`."$1" }
#f5# Memory overview
memusage(){ ps aux | awk '{if (NR > 1) print $5; if (NR > 2) print "+"} END { print "p" }' | dc }
#f5# Show contents of tar file
shtar()   { gunzip -c $1 | tar -tf - -- | $PAGER }
#f5# Show contents of tgz file
shtgz()   { tar -ztf $1 | $PAGER }
#f5# Show contents of zip file
shzip()   { unzip -l $1 | $PAGER }
#f5# Greps signature from file
sig()     { agrep -d '^-- $' "$*" ~/.Signature }
#f5# Unified diff
udiff()   { diff -urd $* | egrep -v "^Only in |^Binary files " }
#f5# (Mis)use \kbd{vim} as \kbd{less}
viless()  { vim --cmd 'let no_plugin_maps = 1' -c "so \$VIMRUNTIME/macros/less.vim" "${@:--}" }

# download video from youtube
ytdl() {
    if ! [[ -n "$2" ]] ; then
        print "Usage: ydtl http://youtube.com/watch?v=.... outputfile.flv">&2
        return 1
    else
        wget -O${2} "http://youtube.com/get_video?"${${${"$(wget -o/dev/null -O- "${1}" | grep -e watch_fullscreen)"}##*watch_fullscreen\?}%%\&fs=*}
    fi
}

# Function Usage: uopen $URL/$file
#f5# Download a file and display it locally
uopen() {
    if ! [[ -n "$1" ]] ; then
        print "Usage: uopen \$URL/\$file">&2
        return 1
    else
        FILE=$1
        MIME=$(curl --head $FILE | grep Content-Type | cut -d ' ' -f 2 | cut -d\; -f 1)
        MIME=${MIME%$'\r'}
        curl $FILE | see ${MIME}:-
    fi
}

# Function Usage: doc packagename
#f5# \kbd{cd} to /usr/share/doc/\textit{package}
doc() { cd /usr/share/doc/$1 && ls }
_doc() { _files -W /usr/share/doc -/ }
check_com compdef && compdef _doc doc

#f5# Make screenshot
sshot() {
    [[ ! -d ~/shots  ]] && mkdir ~/shots
    #cd ~/shots ; sleep 5 ; import -window root -depth 8 -quality 80 `date "+%Y-%m-%d--%H:%M:%S"`.png
    cd ~/shots ; sleep 5; import -window root shot_`date --iso-8601=m`.jpg
}

# list images only
limg() {
    local -a images
    images=( *.{jpg,gif,png}(.N) )

    if [[ $#images -eq 0 ]] ; then
        print "No image files found"
    else
        ls "$@" "$images[@]"
    fi
}

#f5# Create PDF file from source code
makereadable() {
    output=$1
    shift
    a2ps --medium A4dj -E -o $output $*
    ps2pdf $output
}

# zsh with perl-regex - use it e.g. via:
# regcheck '\s\d\.\d{3}\.\d{3} Euro' ' 1.000.000 Euro'
#f5# Checks whether a regex matches or not.\\&\quad Example: \kbd{regcheck '.\{3\} EUR' '500 EUR'}
regcheck() {
    zmodload -i zsh/pcre
    pcre_compile $1 && \
    pcre_match $2 && echo "regex matches" || echo "regex does not match"
}

#f5# List files which have been modified within the last {\it n} days
new() { print -l *(m-$1) }

#f5# Grep in history
greph() { history 0 | grep $1 }
# use colors when GNU grep with color-support
#a2# Execute \kbd{grep -{}-color=auto}
(grep --help 2>/dev/null |grep -- --color) >/dev/null && alias grep='grep --color=auto'
#a2# Execute \kbd{grep -i -{}-color=auto}
alias GREP='grep -i --color=auto'

# one blank line between each line
if [[ -r ~/.terminfo/m/mostlike ]] ; then
    #f5# Watch manpages in a stretched style
    man2() { PAGER='dash -c "sed G | /usr/bin/less"' TERM=mostlike /usr/bin/man "$@" ; }
fi

# d():Copyright 2005 Nikolai Weibull <nikolai@bitwi.se>
# note: option AUTO_PUSHD has to be set
#f5# Jump between directories
d() {
    emulate -L zsh
    autoload -U colors
    local color=$fg_bold[blue]
    integer i=0
    dirs -p | while read dir; do
        local num="${$(printf "%-4d " $i)/ /.}"
        printf " %s  $color%s$reset_color\n" $num $dir
        (( i++ ))
    done
    integer dir=-1
    read -r 'dir?Jump to directory: ' || return
    (( dir == -1 )) && return
    if (( dir < 0 || dir >= i )); then
        echo d: no such directory stack entry: $dir
        return 1
    fi
    cd ~$dir
}

# usage example: 'lcheck strcpy'
#f5# Find out which libs define a symbol
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

#f5# Clean up directory - remove well known tempfiles
purge() {
    FILES=(*~(N) .*~(N) \#*\#(N) *.o(N) a.out(N) *.core(N) *.cmo(N) *.cmi(N) .*.swp(N))
    NBFILES=${#FILES}
    if [[ $NBFILES > 0 ]] ; then
        print $FILES
        local ans
        echo -n "Remove these files? [y/n] "
        read -q ans
        if [[ $ans == "y" ]] ; then
            rm ${FILES}
            echo ">> $PWD purged, $NBFILES files removed"
        else
            echo "Ok. .. than not.."
        fi
    fi
}

# Translate DE<=>EN
# 'translate' looks up fot a word in a file with language-to-language
# translations (field separator should be " : "). A typical wordlist looks
# like at follows:
#  | english-word : german-transmission
# It's also only possible to translate english to german but not reciprocal.
# Use the following oneliner to turn back the sort order:
#  $ awk -F ':' '{ print $2" : "$1" "$3 }' \
#    /usr/local/lib/words/en-de.ISO-8859-1.vok > ~/.translate/de-en.ISO-8859-1.vok
#f5# Translates a word
trans() {
    case "$1" in
        -[dD]*)
            translate -l de-en $2
            ;;
        -[eE]*)
            translate -l en-de $2
            ;;
        *)
            echo "Usage: $0 { -D | -E }"
            echo "         -D == German to English"
            echo "         -E == English to German"
    esac
}

#f5# List all occurrences of programm in current PATH
plap() {
    if [[ $# = 0 ]] ; then
        echo "Usage:    $0 program"
        echo "Example:  $0 zsh"
        echo "Lists all occurrences of program in the current PATH."
    else
        ls -l ${^path}/*$1*(*N)
    fi
}

# Found in the mailinglistarchive from Zsh (IIRC ~1996)
#f5# Select items for specific command(s) from history
selhist() {
    emulate -L zsh
    local TAB=$'\t';
    (( $# < 1 )) && {
        echo "Usage: $0 command"
        return 1
    };
    cmd=(${(f)"$(grep -w $1 $HISTFILE | sort | uniq | pr -tn)"})
    print -l $cmd | less -F
    echo -n "enter number of desired command [1 - $(( ${#cmd[@]} - 1 ))]: "
    local answer
    read answer
    print -z "${cmd[$answer]#*$TAB}"
}

# Use vim to convert plaintext to HTML
#f5# Transform files to html with highlighting
2html() { vim -u NONE -n -c ':syntax on' -c ':so $VIMRUNTIME/syntax/2html.vim' -c ':wqa' $1 &>/dev/null }

# Usage: simple-extract <file>
#f5# Smart archive extractor
simple-extract () {
    if [[ -f $1 ]] ; then
        case $1 in
            *.tar.bz2)  bzip2 -v -d $1      ;;
            *.tar.gz)   tar -xvzf $1        ;;
            *.rar)      unrar $1            ;;
            *.deb)      ar -x $1            ;;
            *.bz2)      bzip2 -d $1         ;;
            *.lzh)      lha x $1            ;;
            *.gz)       gunzip -d $1        ;;
            *.tar)      tar -xvf $1         ;;
            *.tgz)      gunzip -d $1        ;;
            *.tbz2)     tar -jxvf $1        ;;
            *.zip)      unzip $1            ;;
            *.Z)        uncompress $1       ;;
            *)          echo "'$1' Error. Please go away" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Usage: smartcompress <file> (<type>)
#f5# Smart archive creator
smartcompress() {
    if [[ -n $2 ]] ; then
        case $2 in
            tgz | tar.gz)   tar -zcvf$1.$2 $1 ;;
            tbz2 | tar.bz2) tar -jcvf$1.$2 $1 ;;
            tar.Z)          tar -Zcvf$1.$2 $1 ;;
            tar)            tar -cvf$1.$2  $1 ;;
            gz | gzip)      gzip           $1 ;;
            bz2 | bzip2)    bzip2          $1 ;;
            *)
                echo "Error: $2 is not a valid compression type"
                ;;
        esac
    else
        smartcompress $1 tar.gz
    fi
}

# Usage: show-archive <archive>
#f5# List an archive's content
show-archive() {
    if [[ -f $1 ]] ; then
        case $1 in
            *.tar.gz)      gunzip -c $1 | tar -tf - -- ;;
            *.tar)         tar -tf $1 ;;
            *.tgz)         tar -ztf $1 ;;
            *.zip)         unzip -l $1 ;;
            *.bz2)         bzless $1 ;;
            *.deb)         dpkg-deb --fsys-tarfile $1 | tar -tf - -- ;;
            *)             echo "'$1' Error. Please go away" ;;
        esac
    else
        echo "'$1' is not a valid archive"
    fi
}

# It's shameless stolen from <http://www.vim.org/tips/tip.php?tip_id=167>
#f5# Use \kbd{vim} as your manpage reader
vman() { man $* | col -b | view -c 'set ft=man nomod nolist' - }

# function readme() { $PAGER -- (#ia3)readme* }
#f5# View all README-like files in current directory in pager
readme() {
    local files
    files=(./(#i)*(read*me|lue*m(in|)ut)*(ND))
    if (($#files)) ; then
        $PAGER $files
    else
        print 'No README files.'
    fi
}

# function ansi-colors()
#f5# Display ANSI colors
ansi-colors() {
    typeset esc="\033[" line1 line2
    echo " _ _ _40 _ _ _41_ _ _ _42 _ _ 43_ _ _ 44_ _ _45 _ _ _ 46_ _ _ 47_ _ _ 49_ _"
    for fore in 30 31 32 33 34 35 36 37; do
        line1="$fore "
        line2="   "
        for back in 40 41 42 43 44 45 46 47 49; do
            line1="${line1}${esc}${back};${fore}m Normal ${esc}0m"
            line2="${line2}${esc}${back};${fore};1m Bold   ${esc}0m"
        done
        echo -e "$line1\n$line2"
    done
}

# suidfind() { ls -latg $path | grep '^...s' }
#f5# Find all files in \$PATH with setuid bit set
suidfind() { ls -latg $path/*(sN) }

# See above but this is /better/ ... anywise ..
findsuid() {
    print 'Output will be written to ~/suid_* ...'
    $SUDO find / -type f \( -perm -4000 -o -perm -2000 \) -ls > ~/suid_suidfiles.`date "+%Y-%m-%d"`.out 2>&1
    $SUDO find / -type d \( -perm -4000 -o -perm -2000 \) -ls > ~/suid_suiddirs.`date "+%Y-%m-%d"`.out 2>&1
    $SUDO find / -type f \( -perm -2 -o -perm -20 \) -ls > ~/suid_writefiles.`date "+%Y-%m-%d"`.out 2>&1
    $SUDO find / -type d \( -perm -2 -o -perm -20 \) -ls > ~/suid_writedirs.`date "+%Y-%m-%d"`.out 2>&1
    print 'Finished'
}

#f5# Reload given functions
refunc() {
    for func in $argv ; do
        unfunction $func
        autoload $func
    done
}

# a small check to see which DIR is located on which server/partition.
# stolen and modified from Sven's zshrc.forall
#f5# Report diskusage of a directory
dirspace() {
    if [[ -n "$1" ]] ; then
        for dir in $* ; do
            if [[ -d "$dir" ]] ; then
                ( cd $dir; echo "-<$dir>"; du -shx .; echo);
            else
                echo "warning: $dir does not exist" >&2
            fi
        done
    else
        for dir in $path; do
            if [[ -d "$dir" ]] ; then
                ( cd $dir; echo "-<$dir>"; du -shx .; echo);
            else
                echo "warning: $dir does not exist" >&2
            fi
        done
    fi
}

# % slow_print `cat /etc/passwd`
#f5# Slowly print out parameters
slow_print() {
    for argument in "${@}" ; do
        for ((i = 1; i <= ${#1} ;i++)) ; do
            print -n "${argument[i]}"
            sleep 0.08
        done
        print -n " "
    done
    print ""
}

#f5# Show some status info
status() {
    print ""
    print "Date..: "$(date "+%Y-%m-%d %H:%M:%S")""
    print "Shell.: Zsh $ZSH_VERSION (PID = $$, $SHLVL nests)"
    print "Term..: $TTY ($TERM), ${BAUD:+$BAUD bauds, }$COLUMNS x $LINES cars"
    print "Login.: $LOGNAME (UID = $EUID) on $HOST"
    print "System: $(cat /etc/[A-Za-z]*[_-][rv]e[lr]*)"
    print "Uptime:$(uptime)"
    print ""
}

# Rip an audio CD
#f5# Rip an audio CD
audiorip() {
    mkdir -p ~/ripps
    cd ~/ripps
    cdrdao read-cd --device $DEVICE --driver generic-mmc audiocd.toc
    cdrdao read-cddb --device $DEVICE --driver generic-mmc audiocd.toc
    echo " * Would you like to burn the cd now? (yes/no)"
    read input
    if [[ "$input" = "yes" ]] ; then
        echo " ! Burning Audio CD"
        audioburn
        echo " * done."
    else
        echo " ! Invalid response."
    fi
}

# and burn it
#f5# Burn an audio CD (in combination with audiorip)
audioburn() {
    cd ~/ripps
    cdrdao write --device $DEVICE --driver generic-mmc audiocd.toc
    echo " * Should I remove the temporary files? (yes/no)"
    read input
    if [[ "$input" = "yes" ]] ; then
        echo " ! Removing Temporary Files."
        cd ~
        rm -rf ~/ripps
        echo " * done."
    else
        echo " ! Invalid response."
    fi
}

#f5# Make an audio CD from all mp3 files
mkaudiocd() {
    # TODO: do the renaming more zshish, possibly with zmv()
    cd ~/ripps
    for i in *.[Mm][Pp]3; do mv "$i" `echo $i | tr '[A-Z]' '[a-z]'`; done
    for i in *.mp3; do mv "$i" `echo $i | tr ' ' '_'`; done
    for i in *.mp3; do mpg123 -w `basename $i .mp3`.wav $i; done
    normalize -m *.wav
    for i in *.wav; do sox $i.wav -r 44100 $i.wav resample; done
}

#f5# Create an ISO image. You are prompted for\\&\quad volume name, filename and directory
mkiso() {
    echo " * Volume name "
    read volume
    echo " * ISO Name (ie. tmp.iso)"
    read iso
    echo " * Directory or File"
    read files
    mkisofs -o ~/$iso -A $volume -allow-multidot -J -R -iso-level 3 -V $volume -R $files
}

#f5# Set all ulimit parameters to \kbd{unlimited}
allulimit() {
    ulimit -c unlimited
    ulimit -d unlimited
    ulimit -f unlimited
    ulimit -l unlimited
    ulimit -n unlimited
    ulimit -s unlimited
    ulimit -t unlimited
}

viewnfo() {
        if [[ -z "$@" ]]; then
                echo "No filename given."
                echo "Usage: `basename $0` filename(s) [filename(s)]..."
        else
                iconv -f 437 -t UTF8 "$@" | less
        fi

}

# ogg2mp3 with bitrate of 192
ogg2mp3_192() {
    oggdec -o - ${1} | lame -b 192 - ${1:r}.mp3
}

#f5# RFC 2396 URL encoding in Z-Shell
urlencode() {
    setopt localoptions extendedglob
    input=( ${(s::)1} )
    print ${(j::)input/(#b)([^A-Za-z0-9_.!~*\'\(\)-])/%${(l:2::0:)$(([##16]#match))}}
}

#f5# Install x-lite (VoIP software)
getxlite() {
    setopt local_options
    setopt errreturn
    [[ -d ~/tmp ]] || mkdir ~/tmp
    cd ~/tmp

    echo "Downloading http://www.counterpath.com/download/X-Lite_Install.tar.gz and storing it in ~/tmp:"
    if wget http://www.counterpath.com/download/X-Lite_Install.tar.gz ; then
        unp X-Lite_Install.tar.gz && echo done || echo failed
    else
        echo "Error while downloading." ; return 1
    fi

    if [[ -x xten-xlite/xtensoftphone ]] ; then
        echo "Execute xten-xlite/xtensoftphone to start xlite."
    fi
}

#f5# Install skype
getskype() {
    setopt local_options
    setopt errreturn
    echo "Downloading debian package of skype."
    echo "Notice: If you want to use a more recent skype version run 'getskypebeta'."
    wget http://www.skype.com/go/getskype-linux-deb
    $SUDO dpkg -i skype*.deb && echo "skype installed."
}

#f5# Install beta-version of skype
getskypebeta() {
    setopt local_options
    setopt errreturn
    echo "Downloading debian package of skype (beta version)."
    wget http://www.skype.com/go/getskype-linux-beta-deb
    $SUDO dpkg -i skype-beta*.deb && echo "skype installed."
}

#f5# Install gizmo (VoIP software)
getgizmo() {
    setopt local_options
    setopt errreturn
    echo "libgtk2.0-0, gconf2, libstdc++6, libasound2 and zlib1g have to be available. Installing."
    $SUDO apt-get update
    $SUDO apt-get install libgtk2.0-0 gconf2 libstdc++6 libasound2 zlib1g
    wget "$(lynx --dump http://gizmo5.com/pc/download/linux/ | awk '/libstdc\+\+6.*\.deb/ {print $2}')"
    $SUDO dpkg -i gizmo-project*.deb && echo "gizmo installed."
}

#f5# Get and run AIR (Automated Image and Restore)
getair() {
    setopt local_options
    setopt errreturn
    [[ -w . ]] || { echo 'Error: you do not have write permissions in this directory. Exiting.' ; return 1 }
    local VER='1.2.8'
    wget http://puzzle.dl.sourceforge.net/sourceforge/air-imager/air-$VER.tar.gz
    tar zxf air-$VER.tar.gz
    cd air-$VER
    INTERACTIVE=no $SUDO ./install-air-1.2.8
    [[ -x /usr/local/bin/air ]] && [[ -n "$DISPLAY" ]] && $SUDO air
}

#f5# Get specific git commitdiff
git-get-diff() {
    if [[ -z $GITTREE ]] ; then
        GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if ! [[ -z $1 ]] ; then
        ${=BROWSER} "http://kernel.org/git/?p=$GITTREE;a=commitdiff;h=$1"
    else
        echo "Usage: git-get-diff <commit>"
    fi
}

#f5# Get specific git commit
git-get-commit() {
    if [[ -z $GITTREE ]] ; then
        GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if ! [[ -z $1 ]] ; then
        ${=BROWSER} "http://kernel.org/git/?p=$GITTREE;a=commit;h=$1"
    else
        echo "Usage: git-get-commit <commit>"
    fi
}

#f5# Get specific git diff
git-get-plaindiff () {
    if [[ -z $GITTREE ]] ; then
       GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if [[ -z $1 ]] ; then
       echo 'Usage: git-get-plaindiff '
    else
       echo -n "Downloading $1.diff ... "
       # avoid "generating ..." stuff from kernel.org server:
       wget --quiet "http://kernel.org/git/?p=$GITTREE;a=commitdiff_plain;h=$1" -O /dev/null
       wget --quiet "http://kernel.org/git/?p=$GITTREE;a=commitdiff_plain;h=$1" -O $1.diff \
            && echo done || echo failed
    fi
}


# http://strcat.de/blog/index.php?/archives/335-Software-sauber-deinstallieren...html
#f5# Log 'make install' output
mmake() {
    [[ ! -d ~/.errorlogs ]] && mkdir ~/.errorlogs
    make -n install > ~/.errorlogs/${PWD##*/}-makelog
}

#f5# Indent source code
smart-indent() {
    indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs $*
}

# highlight important stuff in diff output, usage example: hg diff | hidiff
#m# a2 hidiff \kbd{histring} oneliner for diffs
check_com -c histring && \
    alias hidiff="histring -fE '^Comparing files .*|^diff .*' | histring -c yellow -fE '^\-.*' | histring -c green -fE '^\+.*'"

# rename pictures based on information found in exif headers
#f5# Rename pictures based on information found in exif headers
exirename() {
    if [[ $# -lt 1 ]] ; then
        echo 'Usage: jpgrename $FILES' >& 2
        return 1
    else
        echo -n 'Checking for jhead with version newer than 1.9: '
        jhead_version=`jhead -h | grep 'used by most Digital Cameras.  v.*' | awk '{print $6}' | tr -d v`
        if [[ $jhead_version > '1.9' ]]; then
            echo 'success - now running jhead.'
            jhead -n%Y-%m-%d_%Hh%M_%f $*
        else
            echo 'failed - exiting.'
        fi
    fi
}

# open file in vim and jump to line
# http://www.downgra.de/archives/2007/05/08/T19_21_11/
j2v() {
    local -a params
    params=(${*//(#m):[0-9]*:/\\n+${MATCH//:/}}) # replace ':23:' to '\n+23'
    params=(${(s|\n|)${(j|\n|)params}}) # join array using '\n', then split on all '\n'
    vim ${params}
}

# get_ic() - queries imap servers for capabilities; real simple. no imaps
ic_get() {
    local port
    if [[ ! -z $1 ]] ; then
        port=${2:-143}
        print "querying imap server on $1:${port}...\n";
        print "a1 capability\na2 logout\n" | nc $1 ${port}
    else
        print "usage:\n  $0 <imap-server> [port]"
    fi
}

# creates a Maildir/ with its {new,cur,tmp} subdirs
mkmaildir() {
    local root subdir
    root=${MAILDIR_ROOT:-${HOME}/Mail}
    if [[ -z ${1} ]] ; then print "Usage:\n $0 <dirname>" ; return 1 ; fi
    subdir=${1}
    mkdir -p ${root}/${subdir}/{cur,new,tmp}
}

#f5# Change the xterm title from within GNU-screen
xtrename() {
    if [[ ${1} != "-f" ]] ; then
        if [[ -z ${DISPLAY} ]] ; then
            printf 'xtrename only makes sense in X11.\n'
            return 1
        fi
    else
        shift
    fi
    if [[ -z ${1} ]] ; then
        printf 'usage: xtrename [-f] "title for xterm"\n'
        printf '  renames the title of xterm from _within_ screen.\n'
        printf '  also works without screen.\n'
        printf '  will not work if DISPLAY is unset, use -f to override.\n'
        return 0
    fi
    print -n "\eP\e]0;${1}\C-G\e\\"
    return 0
}

# hl() highlighted less
# http://ft.bewatermyfriend.org/comp/data/zsh/zfunct.html
if check_com -c highlight ; then
    function hl() {
        local theme lang
        theme=${HL_THEME:-""}
        case ${1} in
            (-l|--list)
                ( printf 'available languages (syntax parameter):\n\n' ;
                    highlight --list-langs ; ) | less -SMr
                ;;
            (-t|--themes)
                ( printf 'available themes (style parameter):\n\n' ;
                    highlight --list-themes ; ) | less -SMr
                ;;
            (-h|--help)
                printf 'usage: hl <syntax[:theme]> <file>\n'
                printf '    available options: --list (-l), --themes (-t), --help (-h)\n\n'
                printf '  Example: hl c main.c\n'
                ;;
            (*)
                if [[ -z ${2} ]] || (( ${#argv} > 2 )) ; then
                    printf 'usage: hl <syntax[:theme]> <file>\n'
                    printf '    available options: --list (-l), --themes (-t), --help (-h)\n'
                    (( ${#argv} > 2 )) && printf '  Too many arguments.\n'
                    return 1
                fi
                lang=${1%:*}
                [[ ${1} == *:* ]] && [[ -n ${1#*:} ]] && theme=${1#*:}
                if [[ -n ${theme} ]] ; then
                    highlight --xterm256 --syntax ${lang} --style ${theme} ${2} | less -SMr
                else
                    highlight --ansi --syntax ${lang} ${2} | less -SMr
                fi
                ;;
        esac
        return 0
    }
    # ... and a proper completion for hl()
    # needs 'highlight' as well, so it fits fine in here.
    function _hl_genarg()  {
        local expl
        if [[ -prefix 1 *: ]] ; then
            local themes
            themes=(${${${(f)"$(LC_ALL=C highlight --list-themes)"}/ #/}:#*(Installed|Use name)*})
            compset -P 1 '*:'
            _wanted -C list themes expl theme compadd ${themes}
        else
            local langs
            langs=(${${${(f)"$(LC_ALL=C highlight --list-langs)"}/ #/}:#*(Installed|Use name)*})
            _wanted -C list languages expl languages compadd -S ':' -q ${langs}
        fi
    }
    function _hl_complete() {
        _arguments -s '1: :_hl_genarg' '2:files:_path_files'
    }
    compdef _hl_complete hl
fi

# Create small urls via http://tinyurl.com using wget(1).
function zurl() {
    [[ -z ${1} ]] && { print "USAGE: zurl <URL>" ; return 1 }

    local PN url tiny grabber search result preview
    PN=${0}
    url=${1}
#   Check existence of given URL with the help of ping(1).
#   N.B. ping(1) only works without an eventual given protocol.
    ping -c 1 ${${url#(ftp|http)://}%%/*} >& /dev/null || \
        read -q "?Given host ${${url#http://*/}%/*} is not reachable by pinging. Proceed anyway? [y|n] "

    if (( $? == 0 )) ; then
#           Prepend 'http://' to given URL where necessary for later output.
            [[ ${url} != http(s|)://* ]] && url='http://'${url}
            tiny='http://tinyurl.com/create.php?url='
            if check_com -c wget ; then
                grabber='wget -O- -o/dev/null'
            else
                print "wget is not available, but mandatory for ${PN}. Aborting."
            fi
#           Looking for i.e.`copy('http://tinyurl.com/7efkze')' in TinyURL's HTML code.
            search='copy\(?http://tinyurl.com/[[:alnum:]]##*'
            result=${(M)${${${(f)"$(${=grabber} ${tiny}${url})"}[(fr)${search}*]}//[()\';]/}%%http:*}
#           TinyURL provides the rather new feature preview for more confidence. <http://tinyurl.com/preview.php>
            preview='http://preview.'${result#http://}

            printf '%s\n\n' "${PN} - Shrinking long URLs via webservice TinyURL <http://tinyurl.com>."
            printf '%s\t%s\n\n' 'Given URL:' ${url}
            printf '%s\t%s\n\t\t%s\n' 'TinyURL:' ${result} ${preview}
    else
        return 1
    fi
}

#f2# Print a specific line of file(s).
linenr () {
# {{{
    if [ $# -lt 2 ] ; then
       print "Usage: linenr <number>[,<number>] <file>" ; return 1
    elif [ $# -eq 2 ] ; then
         local number=$1
         local file=$2
         command ed -s $file <<< "${number}n"
    else
         local number=$1
         shift
         for file in "$@" ; do
             if [ ! -d $file ] ; then
                echo "${file}:"
                command ed -s $file <<< "${number}n" 2> /dev/null
             else
                continue
             fi
         done | less
    fi
# }}}
}

#f2# Find history events by search pattern and list them by date.
whatwhen()  {
# {{{
    local usage help ident format_l format_s first_char remain first last
    usage='USAGE: whatwhen [options] <searchstring> <search range>'
    help='Use' \`'whatwhen -h'\'' for further explanations.'
    ident=${(l,${#${:-Usage: }},, ,)}
    format_l="${ident}%s\t\t\t%s\n"
    format_s="${format_l//(\\t)##/\\t}"
    # Make the first char of the word to search for case
    # insensitive; e.g. [aA]
    first_char=[${(L)1[1]}${(U)1[1]}]
    remain=${1[2,-1]}
    # Default search range is `-100'.
    first=${2:-\-100}
    # Optional, just used for `<first> <last>' given.
    last=$3
    case $1 in
        ("")
            printf '%s\n\n' 'ERROR: No search string specified. Aborting.'
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (-h)
            printf '%s\n\n' ${usage}
            print 'OPTIONS:'
            printf $format_l '-h' 'show help text'
            print '\f'
            print 'SEARCH RANGE:'
            printf $format_l "'0'" 'the whole history,'
            printf $format_l '-<n>' 'offset to the current history number; (default: -100)'
            printf $format_s '<[-]first> [<last>]' 'just searching within a give range'
            printf '\n%s\n' 'EXAMPLES:'
            printf ${format_l/(\\t)/} 'whatwhen grml' '# Range is set to -100 by default.'
            printf $format_l 'whatwhen zsh -250'
            printf $format_l 'whatwhen foo 1 99'
        ;;
        (\?)
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (*)
            # -l list results on stout rather than invoking $EDITOR.
            # -i Print dates as in YYYY-MM-DD.
            # -m Search for a - quoted - pattern within the history.
            fc -li -m "*${first_char}${remain}*" $first $last
        ;;
    esac
# }}}
}

# change fluxbox keys from 'Alt-#' to 'Alt-F#' and vice versa
fluxkey-change() {
    [[ -n "$FLUXKEYS" ]] || local FLUXKEYS="$HOME/.fluxbox/keys"
    if ! [[ -r "$FLUXKEYS" ]] ; then
        echo "Sorry, \$FLUXKEYS file $FLUXKEYS could not be read - nothing to be done."
        return 1
    else
        if grep -q 'Mod1 F[0-9] :Workspace [0-9]' $FLUXKEYS ; then
            echo -n 'Switching to Alt-# mode in ~/.fluxbox/keys: '
            sed -i -e 's|^\(Mod[0-9]\+[: space :]\+\)F\([0-9]\+[: space :]\+:Workspace.*\)|\1\2|' $FLUXKEYS && echo done || echo failed
        elif grep -q 'Mod1 [0-9] :Workspace [0-9]' $FLUXKEYS ; then
            echo -n 'Switching to Alt-F# mode in ~/.fluxbox/keys: '
            sed -i -e 's|^\(Mod[0-9]\+[: space :]\+\)\([0-9]\+[: space :]\+:Workspace.*\)|\1F\2|' $FLUXKEYS && echo done || echo failed
        else
            echo 'Sorry, do not know what to do.'
            return 1
        fi
    fi
}

# retrieve weather information on the console
# Usage example: 'weather LOWG'
weather() {
    [[ -n "$1" ]] || {
        print 'Usage: weather <station_id>' >&2
        print 'List of stations: http://en.wikipedia.org/wiki/List_of_airports_by_ICAO_code'>&2
        return 1
    }

    local PLACE="${1:u}"
    local FILE="$HOME/.weather/$PLACE"
    local LOG="$HOME/.weather/log"

    [[ -d $HOME/.weather ]] || {
        print -n "Creating $HOME/.weather: "
        mkdir $HOME/.weather
        print 'done'
    }

    print "Retrieving information for ${PLACE}:"
    print
    wget -T 10 --no-verbose --output-file=$LOG --output-document=$FILE --timestamping http://weather.noaa.gov/pub/data/observations/metar/decoded/$PLACE.TXT

    if [[ $? -eq 0 ]] ; then
        if [[ -n "$VERBOSE" ]] ; then
            cat $FILE
        else
            DATE=$(grep 'UTC' $FILE | sed 's#.* /##')
            TEMPERATURE=$(awk '/Temperature/ { print $4" degree Celcius / " $2" degree Fahrenheit" }' $FILE| tr -d '(')
            echo "date: $DATE"
            echo "temp:  $TEMPERATURE"
        fi
    else
        print "There was an error retrieving the weather information for $PLACE" >&2
        cat $LOG
        return 1
    fi
}
# }}}

# mercurial related stuff {{{
if check_com -c hg ; then
    # gnu like diff for mercurial
    # http://www.selenic.com/mercurial/wiki/index.cgi/TipsAndTricks
    #f5# GNU like diff for mercurial
    hgdi() {
        for i in $(hg status -marn "$@") ; diff -ubwd <(hg cat "$i") "$i"
    }

    # build debian package
    #a2# Alias for \kbd{hg-buildpackage}
    alias hbp='hg-buildpackage'

    # execute commands on the versioned patch-queue from the current repos
    alias mq='hg -R $(readlink -f $(hg root)/.hg/patches)'

    # diffstat for specific version of a mercurial repository
    #   hgstat      => display diffstat between last revision and tip
    #   hgstat 1234 => display diffstat between revision 1234 and tip
    #f5# Diffstat for specific version of a mercurial repos
    hgstat() {
        [[ -n "$1" ]] && hg diff -r $1 -r tip | diffstat || hg export tip | diffstat
    }

    #f5# Get current mercurial tip via hg itself
    gethgclone() {
        setopt local_options
        setopt errreturn
        if [[ -f mercurial-tree/.hg ]] ; then
            cd mercurial-tree
            echo "Running hg pull for retreiving latest version..."
            hg pull
            echo "Finished update. Building mercurial"
            make local
            echo "Setting \$PATH to $PWD:\$PATH..."
            export PATH="$PWD:$PATH"
        else
            echo "Downloading mercurial via hg"
            hg clone http://selenic.com/repo/hg mercurial-tree
            cd mercurial-tree
            echo "Building mercurial"
            make local
            echo "Setting \$PATH to $PWD:\$PATH..."
            export PATH="$PWD:$PATH"
            echo "make sure you set it permanent via ~/.zshrc if you plan to use it permanently."
            # echo "Setting \$PYTHONPATH to PYTHONPATH=\${HOME}/lib/python,"
            # export PYTHONPATH=${HOME}/lib/python
        fi
    }

fi # end of check whether we have the 'hg'-executable

# get current mercurial snapshot
#f5# Get current mercurial snapshot
gethgsnap() {
    setopt local_options
    setopt errreturn
    if [[ -f mercurial-snapshot.tar.gz ]] ; then
         echo "mercurial-snapshot.tar.gz exists already, skipping download."
    else
        echo "Downloading mercurial snapshot"
        wget http://www.selenic.com/mercurial/mercurial-snapshot.tar.gz
    fi
    echo "Unpacking mercurial-snapshot.tar.gz"
    tar zxf mercurial-snapshot.tar.gz
    cd mercurial-snapshot/
    echo "Installing required build-dependencies"
    $SUDO apt-get update
    $SUDO apt-get install python2.4-dev
    echo "Building mercurial"
    make local
    echo "Setting \$PATH to $PWD:\$PATH..."
    export PATH="$PWD:$PATH"
    echo "make sure you set it permanent via ~/.zshrc if you plan to use it permanently."
}
# }}}

# some useful commands often hard to remember - let's grep for them {{{
# actually use our zg() function now. :)

# Work around ion/xterm resize bug.
#if [[ "$SHLVL" -eq 1 ]]; then
#       if check_com -c resize ; then
#               eval `resize </dev/null`
#       fi
#fi

# enable jackd:
#  /usr/bin/jackd -dalsa -dhw:0 -r48000 -p1024 -n2
# now play audio file:
#  alsaplayer -o jack foobar.mp3

# send files via netcat
# on sending side:
#  send() {j=$*; tar cpz ${j/%${!#}/}|nc -w 1 ${!#} 51330;}
#  send dir* $HOST
#  alias receive='nc -vlp 51330 | tar xzvp'

# debian stuff:
# dh_make -e foo@localhost -f $1
# dpkg-buildpackage -rfakeroot
# lintian *.deb
# dpkg-scanpackages ./ /dev/null | gzip > Packages.gz
# dpkg-scansources . | gzip > Sources.gz
# grep-dctrl --field Maintainer $* /var/lib/apt/lists/*

# other stuff:
# convert -geometry 200x200 -interlace LINE -verbose
# ldapsearch -x -b "OU=Bedienstete,O=tug" -h ldap.tugraz.at sn=$1
# ps -ao user,pcpu,start,command
# gpg --keyserver blackhole.pca.dfn.de --recv-keys
# xterm -bg black -fg yellow -fn -misc-fixed-medium-r-normal--14-140-75-75-c-90-iso8859-15 -ah
# nc -vz $1 1-1024   # portscan via netcat
# wget --mirror --no-parent --convert-links
# pal -d `date +%d`
# autoload -U tetris; zle -N tetris; bindkey '...' ; echo "press ... for playing tennis"
#
# modify console cursor
# see http://www.tldp.org/HOWTO/Framebuffer-HOWTO-5.html
# print $'\e[?96;0;64c'
# }}}

# grml-small cleanups {{{

# The following is used to remove zsh-config-items that do not work
# in grml-small by default.
# If you do not want these adjustments (for whatever reason), set
# $GRMLSMALL_SPECIFIC to 0 in your .zshrc.pre file (which this configuration
# sources if it is there).

if (( GRMLSMALL_SPECIFIC > 0 )) && isgrmlsmall ; then

    unset abk[V]
    unalias    'V'      &> /dev/null
    unfunction vman     &> /dev/null
    unfunction vimpm    &> /dev/null
    unfunction vimhelp  &> /dev/null
    unfunction viless   &> /dev/null
    unfunction 2html    &> /dev/null

    # manpages are not in grmlsmall
    unfunction manzsh   &> /dev/null
    unalias    man2     &> /dev/null
    unalias    man      &> /dev/null
    unfunction man2     &> /dev/null

fi

#}}}

zrclocal

## genrefcard.pl settings {{{

### doc strings for external functions from files
#m# f5 grml-wallpaper() Sets a wallpaper (try completion for possible values)

### example: split functions-search 8,16,24,32
#@# split functions-search 8

## }}}

fortune
export DEVKITPRO=~/devkitPro  #this will need to change if your devkitPro folder is elsewhere
export DEVKITARM=$DEVKITPRO/devkitARM
export PAPATH=$DEVKITPRO/PAlib/lib

if [ "$TERM" != "screen" ] && [ "$SSH_CONNECTION" != "" ]; then
    scr
fi

## END OF FILE #################################################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4

export PERL_LOCAL_LIB_ROOT="/home/florian/perl5";
export PERL_MB_OPT="--install_base /home/florian/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/florian/perl5";
export PERL5LIB="/home/florian/perl5/lib/perl5/x86_64-linux-thread-multi:/home/florian/perl5/lib/perl5";
#export PATH="/home/florian/perl5/bin:/home/florian/perl5/lib/perl5/auto/share/dist/Cope:/opt/android-sdk/platform-tools:$PATH";

export _humblebundle4key=EXXwF42fxYNK
[[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]] && startx
