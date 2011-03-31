# .bashrc

# User specific aliases and functions
# symlink to .bash_profile to avoid confustion and silly os things

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# git completion - prompt stuff relys on this so don't forget it
if [ -f ~/.git_completion.bash ]; then
  . ~/.git_completion.bash
fi

# we use the __git_ps1 function (set by git bash-completion)
# to set the prompt (and window title)
# but sadly git isn't always installed or the completion libraries are missing
_seen_git_ps1=$( type __git_ps1 )
if [ -z "$_seen_git_ps1" ]; then
  function __git_ps1() { true; }
fi

# shopt settings
shopt -s extglob
shopt -s histreedit
shopt -s histappend
shopt -s cmdhist
shopt -s histverify
shopt -s no_empty_cmd_completion
shopt -s huponexit

CVS_RSH=ssh
HISTCONTROL="ignoredups" # ignore duplicate commands in history
HISTIGNORE="ls:&:[bf]g:exit:ll"   # ignore these commands from history
HISTTIMEFORMAT="%D %r "
MAILCHECK=15
PAGER=less
RDIST_RSH="/usr/bin/ssh"
RSYNC_RSH=ssh
VISUAL=vim
EDITOR=$VISUAL
PATH=/opt/local/bin:/opt/local/sbin:$PATH:$HOME/bin/:/usr/local/bin
MANPATH=$MANPATH:/usr/local/man:/opt/local/man

export  CVS_RSH VISUAL PAGER EDITOR \
  RSYNC_RSH HISTIGNORE HISTCONTROL \
  MAILCHECK CVSDIR SVNDIR PRINTER PATH

unset HISTFILESIZE       # never truncate the history file
unset HISTSIZE           # store an unlimited amount of history

# Aliases
alias ndate="date '+%A, %B %d, %Y'"
alias gpgview='gpg --decrypt'
alias gpsort="perl -l -p -i -e '$_ = join(\",\", sort split /,/)'"
alias ls="ls --color=auto"   # gnu ls only -- this gets overwritten for macosx later (bsd/posix)
alias ll="ls -l"
alias l.="ls -la"
alias rootpath="export PATH=/sbin:/usr/sbin:/usr/local/sbin:$PATH"

# work specific rc stuff
if [ -f ~/.bashrc.work ]; then
    source ~/.bashrc.work
fi

# I like to have root commands in my path even if I don't have perms to them
if [ -z "$ROOTPATH_RUN" ]; then
    if [ x`id -u` == x0 ]; then
        rootpath
        export ROOTPATH_RUN="true"
    fi
fi

# silly mac
case $MACHTYPE in
    *-apple-darwin*)
        if [ -f ~/.bashrc.macos ]; then
            source ~/.bashrc.macos
        fi
        ;;
esac

# allow completion snippets in homedir
if [ -n "$BASH_COMPLETION" ]; then
    for completion_snippet in $HOME/.bash_completion.d/*; do
        if [ -f "$completion_snippet" ] ;then
            source $completion_snippet
        fi
    done
fi

# are we an interactive shell?
if [ "$PS1" ]; then
    case $TERM in
    xterm*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}$(__git_ps1 "(%s)"):${PWD/#$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033k${PWD/#$HOME/~}\033\\"'
        ;;
    esac
    # Turn on checkwinsize
    shopt -s checkwinsize
    # set prompt
    PS1="[\u@\h \W]\\$ "
fi


# Functions

# I can never remember the syntax for this, it has the -x to remind and clue me in to what it's doing.
function cpbytar() {
  if [ $# -lt 2 ]; then
      echo "cpbytar [source] [dest]"
  fi
        set -x
  tar cf - $1 | tar xvf - -C $2
        set +x
}

# used for quick finds where I don't want the git objects to show up
function nfind() {
  command find . -name CVS -prune -or -name .git -prune -or -name .svn -prune -or -iname \*$*\* -print
}

# thank dog I don't use cvs much anymore, but if you did and made trees you know why this is here
function cvsdir() {
    IFS='/'
    for x in $*; do
        if [ "$x" ]; then
            mkdir $x && cvs add $x && cd $x
        fi
    done
}

# useful for running git operations on a tree of repos
function super-git() {
    for repo in *; do
        echo "# $repo"
        ( cd $repo && git $* )
        echo "-- -- -- --"
    done
}

# this sets the screen window title prior to launching ssh
# if your remote terminal doesn't have prompt_command setup correctly for screen
function ssh() {
  args=$@
  echo -ne "\033k${args##* }\033\\";
  command ssh "$@";
  # Set window title back here!
}

# page the pi (puppet info) command
function pi() {
  command pi "$@" | less -F
}