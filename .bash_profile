#!/bin/bash
# Custom .bash_profile for OSX / Linux / Unix machines w/ bash or dash
#
#
# This requires some things to be installed:
#   homebrew:
#   - brew install bash-completion 
#   - brew install bash-git-prompt 
#   - brew install kube-ps1 
#   - brew install kubectl 
#   - brew install kubectx 
#   - brew install hub 
#   - brew install kubectx-completion 
#   - brew install terraform 
#   - brew install hub 
#   - brew install gh
#   - brew install azure-cli
#   - brew install awscli
#   - brew install gcloud-cli
#   - brew install --cask google-cloud-sdk

#########################################################################
#  source the global definitions
#########################################################################

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

#########################################################################
#   Custom Environment Variables via hidden files
#########################################################################
#with_env() {
#  (set -a && . ./.env && "$@")
#}

#########################################################################
#   Custom Environment Variables 
#########################################################################
# go development related
export GOPATH="${HOME}/.go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:$GOPATH/bin:${GOROOT}/bin"

###############################################################################
#                       ENABLE BASH COMPLETION                                #
###############################################################################

# homebrew specific bash completion
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi

  # terraform completion via the terraform bin
  #  -- installed via homebrew
  if [ -e "${HOMEBREW_PREFIX}/bin/terraform" ]; then
    complete -C "${HOMEBREW_PREFIX}/bin/terraform" terraform
  fi

  # The next line enables shell command completion for gcloud.
  #  --installed via homebrew
  if [ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc" ]; then
    source "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc";
  fi

  # awscli completion
  #  --installed via homebrew
  if [ -e "${HOMEBREW_PREFIX}/bin/aws_completer" ]; then
    complete -C "${HOMEBREW_PREFIX}/bin/aws_completer" aws
  fi

fi

# aks-engine bash completions
#  -- this is from the following location:
#       
if [ -f /usr/local/bin/aks-engine ]; then
  source <(aks-engine completion)
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
alias la='ls -la'
alias c='clear'
alias g='grep'
alias h='history'
alias hg='history|grep'
alias m='more'
alias p='ps auxwww'
alias pg='ps auxwww | grep'

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

# if we have hub installed;  use it instead of git
if [ -e "/usr/local/bin/hub" ]; then
  alias git="hub"
fi

# kubernetes stuff here son!
if [ -e $(brew --prefix)/bin/kubectl ]; then
  alias k='kubectl'
  complete -F __start_kubectl k
fi

if [ -e $(brew --prefix)/bin/kubectx ]; then
  alias kctx='kubectx'
fi

if [ -e $(brew --prefix)/bin/kubens ]; then
  alias kns='kubens'
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

fi

########################################################################
# Custom Pathes go here yo!
########################################################################

export PATH=$HOME/bin:/usr/local/sbin:$PATH

if [ -e "/Applications/Postgres.app" ]; then
  export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.3/bin
fi

if [ -e "/usr/local/mysql" ]; then
  export PATH="$PATH:/usr/local/mysql:/usr/local/mysql/bin"
fi

if [ -e "/Applications/Visual Studio Code.app" ]; then
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

if [ -d "$HOME/.krew/" ]; then
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# add the google sdk cli tools to the path
#  -- must be installed via homebrew for this to work
if [ -e "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]; then
  source "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
fi

########################################################################
# Helper Functions and Stuff!!!
########################################################################

# password generation function
genpasswd() {
  local l=$1
  [ "$l" == "" ] && l=16
    if [ `uname` == "Darwin" ]; then
      LC_CTYPE=C && LANG=C tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
    else
      tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
    fi
}

###############################################################################
#                        CUSTOM PROMPTS SON!                                  #
###############################################################################
# add kube_ps1 function for a Bash prompt / PS1 for k8s
if [ -f "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh" ]; then
  source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"
fi

# customize Git prompt below with kube_ps1
function prompt_callback() {
  echo -n " $(kube_ps1)"
}

# Bash prompt / PS1 for Git -- prompt is dynamic and uses prompt_callback above
if [ -f "${HOMEBREW_PREFIX}/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="${HOMEBREW_PREFIX}/opt/bash-git-prompt/share"
  source "${HOMEBREW_PREFIX}/opt/bash-git-prompt/share/gitprompt.sh"
  export  GIT_PROMPT_SHOW_UPSTREAM=1
fi

###############################################################################
#              iTerm2 / iTerm2 Preferences                                    #
###############################################################################
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

###############################################################################
#                    Directory Environment Hook                               #
###############################################################################
eval "$(direnv hook bash)"