HISTFILE=~/.zsh_history
HISTSIZE=10023
SAVEHIST=10023

setopt AUTO_CD  # cd to a directory without typing cd
setopt AUTO_CONTINUE  # Jobs are sent SIGCONT when disowned
setopt COMPLETE_ALIASES  # Don't expand aliases on tab completion
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells
setopt LIST_PACKED # Make auto-completion lists more compact visually
setopt NULL_GLOB  # Allow empty wildcard matches

setopt \
    EXTENDED_HISTORY \
    HIST_FIND_NO_DUPS \
    HIST_IGNORE_ALL_DUPS \
    HIST_REDUCE_BLANKS \
    HIST_SAVE_NO_DUPS \
    INC_APPEND_HISTORY \
    SHARE_HISTORY

unsetopt BEEP

typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive auto-completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # Colors in file menu
zstyle ':completion:*:default' menu 'select=0'
zstyle ':completion:*' rehash true  # Re-load list of commands on the PATH

autoload -Uz compinit bashcompinit
compinit
bashcompinit

type zoxide &> /dev/null && eval "$(zoxide init zsh)"

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

path_prepend ~/local/bin ~/bin ~/monorepo/bin
# Ubuntu installs fd into this directory for some reason
path_prepend /usr/lib/cargo/bin

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
eval "${ls_cmd}" /etc &> /dev/null && alias ls="${ls_cmd}"
ls_cmd="ls --color=auto --ignore-backups --hide=\*.aux --hide=\*.toc --hide=Thumbs.db --group-directories-first"
eval "${ls_cmd}" /etc &> /dev/null && alias ls="${ls_cmd}"

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
type fdupes   &> /dev/null && alias fdupes="fdupes --noempty --order name"
type xinit    &> /dev/null && alias myxinit="xinit -- -nolisten tcp"
type scp      &> /dev/null && alias scp="scp -p"
type sftp     &> /dev/null && alias sftp="sftp -p"
type rmaxima  &> /dev/null && alias maxima="rmaxima"
type loffice  &> /dev/null && alias loffice="loffice --nologo"
type lowriter &> /dev/null && alias lowriter="lowriter --nologo"
type localc   &> /dev/null && alias localc="localc --nologo"
type opera    &> /dev/null && alias opera="opera -nomail -nolirc"
type git      &> /dev/null && alias gitcolordiff="git --no-pager diff --color"

if [ "$(lsb_release --codename --short)" != focal ]; then
    # In Ubuntu Focal, looks like ibus is used when GNOME Shell is used.
    export GTK_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export QT_IM_MODULE=fcitx
fi

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
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

## Set up browser
## This needs to be done here rather than desktop autostart script because of the alias lines
type chromium      &> /dev/null && export BROWSER=chromium
type google-chrome &> /dev/null && export BROWSER=google-chrome

if type chromium &> /dev/null; then
    if type ssh &> /dev/null; then
        function socks_chrome() {
            ssh -N -D 6060 -C "${1}" -f -o ServerAliveInterval=90
            chromium --proxy-server="socks://localhost:6060" http://ip4.me/
        }
    fi

    alt_chromium_profile="/home/swipper/.Alt-P-Chromium-Profile"
    if [ -e "${alt_chromium_profile}" ]; then
        function alt-chromium() {
            chromium --user-data-dir="${alt_chromium_profile}" "$@"
        }
    fi

    alias unifi="chromium --user-data-dir=/home/swipper/.unifi-chrome-profile --app=https://unifi.rms.nyc:8443"
    alias printer_web_uis="chromium --user-data-dir=/home/swipper/.printer-chrome-profile http://192.168.1.114/ http://192.168.1.77/"
fi

if type firefox &> /dev/null; then
    alt_firefox_profile="/home/swipper/.Alt-P-Firefox-Profile"
    if [ -e "${alt_firefox_profile}" ]; then
        function alt-firefox() {
            firefox --profile "${alt_firefox_profile}" "$@"
        }
    fi
fi

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

type hg &> /dev/null && function hgcolordiff {
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
    for i in {1..${1}}; do while : ; do : ; done & done
}

function field {
    awk '{print $'"${1}"';}'
}

function zlocate {
    local query=${1}
    (
        xzcat $(printf '%s\n' /Z/Swipper/Archive/z3-listing-* | sort | tail --lines 1)
        find / -xdev 2> /dev/null
    ) | grep --ignore-case "${query}"
}

function most_recently_modified_files {
    find -xdev -type f -printf "%TY-%Tm-%TdT%TH-%TM-%TS %p\n" | sort
    # Also: find -xdev -type f -exec stat --printf="%y %n\n" \{\} + | sort
}

function binary_compare {
    diff -u <(xxd "${1}") <(xxd "${2}")
}

# Set up ssh-agent
export SSH_AUTH_SOCK=/tmp/swipper-ssh-agent.sock
pid=($(pgrep -u swipper ssh-agent))
if [ $? -ne 0 ]; then
    ssh-agent -a "${SSH_AUTH_SOCK}"
    pid=($(pgrep -u swipper ssh-agent))
fi
export SSH_AGENT_PID="${pid[1]}"

if type fzf &> /dev/null; then
    [ -e /usr/share/fzf/key-bindings.zsh ]              && . /usr/share/fzf/key-bindings.zsh
    [ -e /usr/share/fzf/completion.zsh ]                && . /usr/share/fzf/completion.zsh
    [ -e /usr/share/doc/fzf/examples/completion.zsh ]   && . /usr/share/doc/fzf/examples/completion.zsh
    [ -e /usr/share/doc/fzf/examples/key-bindings.zsh ] && . /usr/share/doc/fzf/examples/key-bindings.zsh

    if [ -f ~/.fd_wrapper.sh ]; then
            export FZF_CTRL_T_COMMAND="bash ~/.fd_wrapper.sh"
    elif type fd &> /dev/null; then
        if [ "$(lsb_release --short --id)" = "Ubuntu" ]; then
            # Ubuntu ships an older version of fd (older than 8.3.0)
            export FZF_CTRL_T_COMMAND="fd --color never --threads 10"
        else
            export FZF_CTRL_T_COMMAND="fd --color never --threads 10 --one-file-system"
        fi
    else
        export FZF_CTRL_T_COMMAND="ag -g ."
    fi
fi

function monorepo_clone {
    clone_name="${1}"
    cd ~/src/vanilla
    git pull
    cd ~/src
    cp -ai vanilla "${1}"
    cd "${1}"
}

for file in ~/.zshrc.d/*.sh; do
    . "${file}"
done
