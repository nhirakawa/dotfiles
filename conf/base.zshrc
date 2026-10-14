# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Custom themes/plugins live outside the oh-my-zsh checkout
ZSH_CUSTOM="${ZSH_CUSTOM:=${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-zsh}"

# No oh-my-zsh theme - starship (initialized below) handles the prompt.
# Set ZSH_THEME before sourcing this file to use one anyway.
ZSH_THEME="${ZSH_THEME:-}"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# PATH is set up before the plugin checks below so they can find tools in
# ~/.local/bin, ~/.cargo/bin, etc.
# Keep only the first occurrence of each entry; system dirs go last so
# package managers (e.g. Homebrew) take precedence
typeset -U path
path=(~/.local/bin $path /usr/local/bin /usr/bin /bin /usr/sbin /sbin /usr/local/sbin)

if (( $+commands[go] ))
then
  export GOPATH=~/src/golang
  path=($GOPATH/bin $path)
fi

if [ -d ~/.cargo/bin ]
then
  path=(~/.cargo/bin $path)
fi

# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(ssh-agent git nvm)

if (( $+commands[http] ))
then
  plugins+=(httpie)
fi

if (( $+commands[rustc] ))
then
  plugins+=(rust)
fi

if (( $+commands[tmux] ))
then
  plugins+=(tmux)
fi

if (( $+commands[direnv] ))
then
  plugins+=(direnv)
fi

# User configuration

# https://github.com/ohmyzsh/ohmyzsh/tree/1514145a09140425b914e9cd98fc1d638a8c4003/plugins/nvm#lazy-startup
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' autoload yes
zstyle ':omz:plugins:nvm' silent-autoload yes

source $ZSH/oh-my-zsh.sh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
#export SSH_KEY_PATH="~/.ssh/id_rsa"

# git
alias gpf="git push --force-with-lease"

#mvn
alias mvnpack="mvn clean package"
alias mvnda="mvn clean dependency:analyze-only"
alias mvncc="mvn clean compile"
alias mvncv="mvn clean verify"
alias mvnsort="mvn sortpom:sort -Dsort.sortDependencies=scope,groupId,artifactId"

# Timestamp functions
date_str() {
  date +%Y%m%d
}

time_str() {
  date +%H%M%S
}

datetime_str() {
  date +%Y%m%d-%H%M%S
}

if (( $+commands[atuin] ))
then
  eval "$(atuin init zsh)"
fi

if (( $+commands[starship] ))
then
  eval "$(starship init zsh)"
fi

if [ -e ~/.config/dotfiles.zsh ]
then
  source ~/.config/dotfiles.zsh
fi

