HISTFILE=~/.zsh_history
HISTSIZE=10023
SAVEHIST=10023

setopt incappendhistory \
    autocd \
    histfindnodups \
    histreduceblanks \
    histignorealldups \
    histsavenodups \
    autolist \
    listpacked \
    completealiases \
    EXTENDED_HISTORY \
    sharehistory \
    nullglob

unsetopt beep

typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' menu 'select=0'

autoload -Uz compinit colors
compinit

autoload zkbd

## Fancy colors for GNU ls
type dircolors &> /dev/null && eval `dircolors -b`

_green="%{\e[1;32m%}"
_blue="%{\e[1;34m%}"
_lavender="%{\e[1;38;5;177m%}"
_prettyblue="%{\e[38;5;33m%}"
_apple="%{\e[1;38;5;156m%}"
_hyored="%{\e[38;5;160m%}"
_pine="%{\e[1;38;5;34m%}"
_mauve="%{\e[1;38;5;125m%}"
_slate="%{\e[1;38;5;147m%}"
_reset="%{\e[00m%}"

# export LANG=ja_JP.utf8

if [ "${STY}" ] ; then
    PS1="$(print ${_blue}'%*' ${_green}${STY} ${_blue}'%?' ${_green}'%n@%m' ${_blue}'%~' \$ ${_reset})"
elif [ "${TERM}" != 'xterm' ] && [ "${TERM}" != 'xterm-256color' ] ; then
    PS1="$(print ${_green}'%*' ${_blue}'%?' ${_green}'%n@%m' ${_blue}'%~' \$ ${_reset})"
else
    function title() {
        print -Pn "\e]0;${(%):-%n@%m: %~}\a"
    }

    ## Every now and then, randomly change prompt to colors chosen by Hyo.
    function random_ps1() {
        if [ $RANDOM -le 32256 ]; then
            PS1="$(print ${_slate}'%*' ${_mauve}'%?' ${_lavender}'%n@%m' ${_prettyblue}'%~' \$ ${_reset})"
        else
            PS1="$(print ${_slate}'%*' ${_pine}'%?' ${_apple}'%n@%m' ${_hyored}'%~' \$ ${_reset})"
        fi
    }

    precmd_functions+=random_ps1
    precmd_functions+=title

    # less colors for man pages
    export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
    export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
    export LESS_TERMCAP_me=$'\E[0m'           # end mode
    export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
    export LESS_TERMCAP_so=$'\E[01;38;5;135m' # begin standout-mode - info box
    export LESS_TERMCAP_ue=$'\E[0m'           # end underline
    export LESS_TERMCAP_us=$'\E[04;38;5;72m'  # begin underline
fi

function path_prepend {
    for i; do
        [ -d "${i}" ] && path=("${i}" $path)
    done
    export PATH
}

path_prepend ~/local/bin ~/bin

## Set up editor
type nano  &> /dev/null && export EDITOR="nano"
type pico  &> /dev/null && export EDITOR="pico"
type emacs &> /dev/null && export EDITOR="emacs"
type vim   &> /dev/null && export EDITOR="vim"

export SUDO_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

export PAGER="less"
export LESS="--LONG-PROMPT --RAW-CONTROL-CHARS --QUIET --IGNORE-CASE"

## Set up aliases
alias ln="ln -i"
alias mv="mv -i"
alias cp="cp -i"
alias cal="cal -y"
alias mkdir="mkdir -v"

ls_cmd="ls -G" ## BSD
eval "${ls_cmd}" / &> /dev/null && alias ls="${ls_cmd}"
ls_cmd="ls --color=auto --ignore-backups --hide=\*.aux --hide=\*.toc --hide=Thumbs.db --group-directories-first"
eval "${ls_cmd}" / &> /dev/null && alias ls="${ls_cmd}"

alias rm="rm -i"
rm -f --one-file-system &> /dev/null && alias rm="rm -i --one-file-system"

df_cmd="df -c" ## BSD
eval "${df_cmd}" / &> /dev/null && alias df="${df_cmd}"
df_cmd="df -t ext3 -t ext4 -t xfs -t cifs -t nfs -t nfs4 -t fuse.sshfs -t fuseblk -t reiserfs -t simfs -t vfat -t zfs -t btrfs --total --print-type"
eval "${df_cmd}" / &> /dev/null && alias df="${df_cmd}"

grep_cmd="grep --color=auto"
eval "${grep_cmd}" . < /etc/resolv.conf &> /dev/null && alias grep="${grep_cmd}"

egrep_cmd="egrep --color=auto"
eval "${egrep_cmd}" . < /etc/resolv.conf &> /dev/null && alias egrep="${egrep_cmd}"

type emacs    &> /dev/null && alias emacs="emacs -nw"
type ifstat   &> /dev/null && alias ifstat="ifstat -b"
type nautilus &> /dev/null && alias nautilus="nautilus --no-desktop"
type fdupes   &> /dev/null && alias fdupes="fdupes --noempty"
type xinit    &> /dev/null && alias myxinit="xinit -- -nolisten tcp"
type scp      &> /dev/null && alias scp="scp -p"
type sftp     &> /dev/null && alias sftp="sftp -p"
type rmaxima  &> /dev/null && alias maxima="rmaxima"
type loffice  &> /dev/null && alias loffice="loffice --nologo"
type lowriter &> /dev/null && alias lowriter="lowriter --nologo"
type localc   &> /dev/null && alias localc="localc --nologo"
type opera    &> /dev/null && alias opera="opera -nomail -nolirc"
type git      &> /dev/null && alias gitcolordiff="git --no-pager diff --color"

## This may be required for Qt to find the Oxygen style
## This is here instead of desktop autostart scripts so it works with X forwarding
# export QT_PLUGIN_PATH=~/.kde4/lib/kde4/plugins/:/usr/lib/kde4/plugins/

## ibus for international character sets
## This is here instead of desktop autostart scripts so it works with X forwarding
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[7~" beginning-of-line
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\e[5D" backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[8~" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey \\C-R history-incremental-search-backward
bindkey \\C-K kill-line

## Set up browser
## This needs to be done here rather than desktop autostart script because of the alias lines
type chromium      &> /dev/null && export BROWSER=chromium
type google-chrome &> /dev/null && export BROWSER=google-chrome

## Show environment variables except LESS variables, which include control characters.
function safeenv() {
    env | grep -v ^LESS_ | sort
}

## MV with progress bar
type rsync &> /dev/null && alias mv_progress="rsync --archive --progress --remove-source-files --hard-links --acls --xattrs --partial --stats --itemize-changes --human-readable"

## Show how much ZFS-on-Linux ARC is used
[ -e /proc/spl/kstat/zfs/arcstats ] && function arc {
    awk '
        $1 == "size" {
            printf "%0.2f GiB\n", ($3 / 1024.0^3);
        }
    ' /proc/spl/kstat/zfs/arcstats
}

function hgcolordiff {
    hg diff "$@" | awk '
        {
            if(/^diff -r/)               {print "\033[1;34m" $0 "\033[1;000m"}
            else if(/^---/ || /^\+\+\+/) {print "\033[1;36m" $0 "\033[1;000m"}
            else if(/^-/)                {print "\033[1;31m" $0 "\033[1;000m"}
            else if(/^+/)                {print "\033[1;32m" $0 "\033[1;000m"}
            else                         {print;}
        }
    '
}

## Force LibreOffice to use the generic theme rather to attempt GTK or KDE integration
export SAL_USE_VCLPLUGIN=gen

## By default, connect to localhost for virsh
type virsh &> /dev/null && export LIBVIRT_DEFAULT_URI=qemu:///system

# Spin up n processes that just infinitely loop
function loop {
    for i in {1..${1}}; do while : ; do : ; done &  done
}

function field {
    awk '{print $'"${1}"';}'
}

for file in ~/.zshrc.d/*.sh; do
    . "${file}"
done
