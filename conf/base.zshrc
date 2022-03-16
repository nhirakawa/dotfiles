# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
 
ZSH_THEME="${ZSH_THEME:=robbyrussell}"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(httpie mvn python pylint pip ssh-agent tmux git rust)

if [ "$(uname -s)" '==' "Darwin" ]; then
  plugins+=(macos brew)
fi

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin"

if [ "$(uname -s)" '==' "Darwin" ]
then
  export JAVA_HOME=$(/usr/libexec/java_home)
  PATH="/usr/local/opt/python/libexec/bin:$PATH"
fi

if [ -n "$(command -v go)" ]
then
  mkdir -p ~/src/golang
  export GOPATH=~/src/golang
  export PATH=$GOPATH/bin:$PATH
fi

if [ -d ~/.cargo/bin ]
then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

source $ZSH/oh-my-zsh.sh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
#export SSH_KEY_PATH="~/.ssh/id_rsa"

# git
alias gpf="git push --force-with-lease"

#mvn
alias mvnpack="mvnc package"
alias mvnda="mvnc dependency:analyze-only"
alias mvncc="mvn clean compile"
alias mvncv="mvn clean verify"
alias mvnsort="mvn sortpom:sort -Dsort.sortDependencies=scope,groupId,artifactId"

if [ -f ~/.config/dotfiles.zsh ]
then
  source ~/.config/dotfiles.zsh
fi
