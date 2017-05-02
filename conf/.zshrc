# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git httpie mvn nmap node npm bower grunt gulp osx brew python pylint pip ssh-agent tmux)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin"

if [ "$(uname -s)" '==' "Darwin" ]
then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

if [ ! -d "~/src/golang" ]
then
  mkdir -p ~/src/golang
fi
export GOPATH=~/src/golang
export PATH=$GOPATH/bin:$PATH

source $ZSH/oh-my-zsh.sh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"

alias mvnpack="mvnc package"
alias mvnda="mvnc dependency:analyze-only"
alias gpf="git push --force-with-lease"
alias mvncc="mvnc compile"
