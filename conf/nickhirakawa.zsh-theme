# colors
MACHINE_NAME_COLOR="#af00ff"
KUBE_COLOR="#005fd7"
KUBE_CLUSTER_COLOR="#005FFF"
KUBE_NAMESPACE_COLOR="#0087ff"
DIRECTORY_COLOR="#87ff00"
GIT_COLOR="#FFAB08"

prompt_indicator() {
   echo $'%B\u276f%b'
}

machine_name() {
  echo "%B%F{$MACHINE_NAME_COLOR}$(uname -n)%f%b"
}

kube_cluster() {
  if [[ ! -a ~/.kube/config ]]; then
    return
  fi

  echo "%B%F{$KUBE_CLUSTER_COLOR}$(grep -m 1 'current-context:' ~/.kube/config | cut -d ' ' -f 2)%f%b"
}

kube_namespace() {
  if command -v native-kubectl &> /dev/null
  then
    echo -n "$(native-kubectl config get-contexts 2>/dev/null | grep '*' | awk '{ print $5 }')"
  else
    echo -n "$(kubectl config get-contexts 2>/dev/null | grep '*' | awk '{ print $5 }')"
  fi
}

kubernetes() {
  if ! command -v kubectl &> /dev/null
  then
    return
  fi

  KUBE_NAMESPACE="$(kube_namespace)"

  if [[ $KUBE_NAMESPACE = *[![:space:]]* ]]; then
    echo -n "%B%F{$KUBE_COLOR}kube:%f%b($(kube_cluster)%b/%B%F{$KUBE_NAMESPACE_COLOR}$KUBE_NAMESPACE%f%b)%f%b"
  else
    echo -n "%B%F{$KUBE_COLOR}kube:%f%b(%B$(kube_cluster)%b)%f%b"
  fi
}

directory() {
   echo "%B%F{$DIRECTORY_COLOR}%2~%f%b"
}

current_time() {
   echo "%{$fg[white]%}%*%{$reset_color%}"
}

git_prompt() {
  git="$(git_prompt_info)"

  if [ ! -z $git ]; then
    echo -n "%B%F{$GIT_COLOR}$git%f%b"
  fi
}

prompt() {
  MACHINE_NAME="$(machine_name)"
  KUBE="$(kubernetes)"
  GIT="$(git_prompt)"

#  if [[ -z "$KUBE" && -z "$GIT" ]]; then
#    echo -n " $(directory)"
#    return
#  fi

  echo -n "[ "

  if [ ! -z "$MACHINE_NAME" ]; then
    echo -n "$MACHINE_NAME"
    echo -n " | "
  fi

  if [ ! -z "$KUBE" ]; then
    echo -n "$KUBE"
    echo -n " | "
  fi

  echo -n "$(directory)"

  if [[ $GIT = *[![:space:]]* ]]; then
    echo -n " | " 
    echo -n "$GIT"
  fi

  echo -n " ]%k"
}

# set the git_prompt_info text
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# set the git_prompt_status text
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%} ✈%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} ✭%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%} ➦%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%} ✂%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%} ✱%{$reset_color%}"

PROMPT='$(prompt)
$(prompt_indicator) '
RPROMPT='$(git_prompt_status) $(current_time)'
