#!/bin/bash
# Custom .bash_profile for OSX / Linux / Unix machines w/ bash or dash

#########################################################################
#  source the global definitions
#########################################################################

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

#########################################################################
#  aliases ftw!!!
#########################################################################

if [ `uname` == "Darwin" ]; then
  # color on BSD version of bash works differently
  alias ls='ls -GF'
else
  # default to the linux/gnu way of doing things!
  alias ls='ls -F --color="always"'
fi


alias l='ls -la'
alias l.='ls -d .*'
alias ll='ls -l'
alias k='kill -9'
alias la='ls -la'
alias c='clear'
alias g='grep'
alias h='history'
alias hg='history|grep'
alias m='more'
alias p='ps auxwww'
alias pg='ps auxwww | grep'
#alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
#alias whois='jwhois'

# we all hate vi, so if vim is installed default to that as the vi editor
if [ -e "`which vim`" ]; then
  alias vi="vim"
fi

# if git exists, let's fix our stupid typos ;)
if [ -e "`which git`" ]; then
  alias got="git"
  alias gc="git checkout"
  alias gcb="git checkout -b"
  alias gm="git merge"
fi

# if thefuck is on the system, them alias it as fuck or fuckme
if [ -e "/usr/local/bin/thefuck" ]; then
  alias fuck='$(thefuck $(fc -ln -1))'
fi

#########################################################################
##  My OSX Specific Aliases here ##
#########################################################################

if [ `uname` == "Darwin" ]; then
  
  # Check for MacVim and setup alias if found
  if [ -e "/usr/local/opt/macvim/MacVim.app" ]; then 
    alias vim="/usr/local/opt/macvim/MacVim.app/Contents/MacOS/Vim" 
    alias gvim="mvim"
  fi

  # Check for Sublime Text and setup alias if found
  if [ -e "/Applications/Sublime Text.app" ]; then 
    alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl' 
  fi

  # Check for IntelliJ IDEA (pro version) and setup an alias for it
  if [ -e "/Applications/IntelliJ IDEA 14.app" ]; then
    alias idea="/Applications/IntelliJ\ IDEA\ 14.app/Contents/MacOS/idea"
  fi
fi

########################################################################
# Custom Pathes go here yo!
########################################################################

export PATH=$HOME/bin:$PATH

if [ -e "/Applications/Postgres.app" ]; then
  export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.3/bin
fi

# Add RVM to PATH for scripting
#if [ -e "$HOME/.rvm/bin" ]; then
#	export PATH="$PATH:$HOME/.rvm/bin" 
#fi

if [ -e "/usr/local/mysql" ]; then
  export PATH="$PATH:/usr/local/mysql:/usr/local/mysql/bin"
fi

########################################################################
# Helper Functions and Stuff!!!
########################################################################

# Load RVM into a shell session *as a function*
#if [ -e "$HOME/.rvm/bin" ]; then
#	[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
#fi

# OSX Specific here
if [ `uname` == "Darwin" ]; then
  # is docker is on the machine, let's source it's info
  if [ -e "/usr/local/bin/docker" ]; then
    eval $(docker-machine env default)
  fi

  # bash-completion setup?  (homebrew here)
  if [ -d $(brew --prefix)/etc/bash_completion.d ]; then
    . $(brew --prefix)/etc/bash_completion.d/*
  fi

  # awscli completion
  if [ -e "/usr/local/bin/aws_completer" ]; then
    complete -C '/usr/local/bin/aws_completer' aws
  fi
fi

# passwords are a nice thing to have handy
genpasswd() {
  local l=$1
  [ "$l" == "" ] && l=16
    if [ `uname` == "Darwin" ]; then
      LC_CTYPE=C && LANG=C tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
    else
      tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
    fi
}

########################################################################
#  let's make a custom prompt based on the terminals!!!  yay!!
########################################################################
         RED="\[\033[0;31m\]"
      YELLOW="\[\033[01;33m\]"
       GREEN="\[\033[01;32m\]"
        BLUE="\[\033[0;34m\]"
        CYAN="\[\033[0;36m\]"
   LIGHT_RED="\[\033[1;31m\]"
 LIGHT_GREEN="\[\033[1;32m\]"
LIGHT_YELLOW="\[\033[0;33m\]"
       WHITE="\[\033[1;37m\]"
  LIGHT_GRAY="\[\033[0;37m\]"
  COLOR_NONE="\[\e[0m\]"

function parse_git_branch {

  git rev-parse --git-dir &> /dev/null
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"
  #if [[ ! ${git_status}} =~ "working directory clean" ]]; then
  if [[ ! ${git_status}} =~ "nothing to commit, working tree clean" ]]; then
    state="${RED}⚡ "
  fi
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="${BLUE}↑"
    else
      remote="${BLUE}↓"
    fi
  fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${BLUE}↕"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo " (${branch})${remote}${state}"
  fi
}
function prompt_func() {
  previous_return_value=$?;
  #prompt="${TITLEBAR}${BLUE}[${RED}\w${GREEN}$(parse_git_branch)${BLUE}]${COLOR_NONE} "
  #prompt="\h:${USER_COLOR}\u${COLOR_NONE}:${YELLOW}\w${GREEN}$(parse_git_branch)${COLOR_NONE}:"
  prompt="${GREEN}[ ${LIGHT_YELLOW}\t ${GREEN}- ${LIGHT_RED}\u ${COLOR_NONE}@ ${CYAN}\h ${LIGHT_GREEN}- ${BLUE}\w ${GREEN}] ${GREEN}$(parse_git_branch)${COLOR_NONE}:"
  if test $previous_return_value -eq 0
  then
    PS1="${prompt}\\$ "
    #PS1="${prompt}➔ "
  else
    PS1="${prompt}${RED}➔${COLOR_NONE} "
  fi
}

PROMPT_COMMAND=prompt_func
#export PS1="${GREEN}[ ${YELLOW}\t${GREEN} - ${LIGHT_RED}\u ${COLOR_NONE} @ ${CYAN}\h ${LIGHT_GREEN}- ${BLUE}\w ${GREEN} ] \$ "


# iterm2 shell integration stuff here!!
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
