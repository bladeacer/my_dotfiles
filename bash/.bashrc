# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
# alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

alias vf='find -type f | fzf --layout reverse --info inline --border --preview "bat --color=always --style=numbers,changes {}" --preview-window '~3' --bind "enter:execute(vim {})"'
alias vg='rg --files -g "!node_modules/" | fzf --layout reverse --info inline --border --preview "bat --color=always --style=numbers,changes {}" --bind "enter:execute(vim {})"'
alias gla='git log --oneline -a'
alias glg='git log --oneline --decorate --all --graph'
alias gco='git count-objects --human-readable'
alias aic='ascii-image-converter'

export STARSHIP_CONFIG=~/my_dotfiles/.config/starship/starship.toml
export PDF_FMT_CONFIG_PATH=~/my_dotfiles/pdf-fmt/pdf-fmt.yaml

eval "$(starship init bash)"
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

eval "$(zoxide init bash)"
# alias cd='z'
set -o vi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_CTRL_T_OPTS="
--walker-skip .git,node_modules,target
--preview 'bat -n --color=always {}'
--bind 'ctrl-/:change-preview-window(down|hidden|)'"
export BAT_THEME="Nord"

vman() {
    # export MANPAGER="col -b" # for FreeBSD/MacOS

    # Make it read-only
    eval 'man $@ | vim -MR +"set filetype=man" -'

    unset MANPAGER
}

alias ls='eza --icons --group-directories-first'
alias la='eza --icons --group-directories-first -a'
alias v='vim'
alias bat="bat --color=always --style=numbers,changes"

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

function fzf_man_search() {
    man -k . | fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --prompt="MAN PAGE > " \
        --ansi \
        --preview-window="right:60%" \
        --preview '
            # Extract the command name, which is the first word before the space
            CMD=$(echo {} | awk "{print \$1}")
            
            # Use TTY-safe man command that forces text output and pipe to less -R
            # The env PAGER=cat ensures man prints to stdout without using a pager
            # col -b removes troff/nroff bolding codes, and head limits the preview
            env PAGER=cat man "$CMD" 2>/dev/null | col -b | less -R
        ' | \
    awk '{print $1}' | \
    xargs -r man
}

function fzf_tldr_search() {
    if ! command -v tldr &> /dev/null; then
        echo "Error: 'tldr' command not found. Please install it."
        return 1
    fi
    
    tldr --list | fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --prompt="TLDR PAGE > " \
        --ansi \
        --preview-window="right:60%" \
        --preview 'tldr {} | less -R' | \
    xargs -r tldr
}

alias fm='fzf_man_search'
alias ft='fzf_tldr_search'
alias get_size='du -sh ./*'
alias jl='jupyter lab'
alias rf='fcitx5-remote -r'
alias py_update='pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U'
alias tk='tokei'

export EDITOR=vim
export BROWSER=waterfox
export PATH="~/go/bin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="~/Desktop/projects/mnemosync:$PATH"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

activate-venv() {
    source ./.venv/bin/activate
}
create-venv() {
    python -m venv .venv
}

pacQi() {
    pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h
}
# Load pyenv automatically by appending
# the following to
# ~/.bash_profile if it exists, otherwise ~/.profile (for login shells)
# and ~/.bashrc (for interactive shells) :

pyenv-init() {
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
}

conda-init() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/data/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/data/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/home/data/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/data/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
}
