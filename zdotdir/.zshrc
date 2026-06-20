#
# sheldon
# 
eval "$(sheldon source)"

# 
# starship
# 
eval "$(starship init zsh)"

# 
# asdf
# 
#. "$HOME/.asdf/asdf.sh"
# append completions to fpath
#fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
#autoload -Uz compinit && compinit

# 
# pnpm
# 
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

#
# history
#
export HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}" 
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE

setopt BANG_HIST              # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY       # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY          # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS      # Do not display a previously found event.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS      # Do not write a duplicate event to the history file.
setopt HIST_VERIFY            # Do not execute immediately upon history expansion.
setopt HIST_BEEP              # Beep when accessing non-existent history.

#
# ls color if dont install eza
#
# function is-callable {
#   (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
# }
# if is-callable 'dircolors'; then
#   eval "$(dircolors --sh $HOME/.dir_colors(N))"
# else
#   export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
# fi

#
# kubectl
#
#source <(kubectl completion zsh)

function _fzf_kubectl_pod_describe() {
  local selection=`kubectl get pods -A | fzf --header-lines=1 --query="$*" --select-1 -e `
  if [ $selection = "" ]; then
    return 0
  fi

  local namespace=`echo $selection | awk '{ print $1 }'`
  local pod=`echo $selection | awk '{ print $2 }'`

  print -z "kubectl describe pod ${pod} -n ${namespace}"
}

alias kcdpod=_fzf_kubectl_pod_describe

#
# fzf
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(~/.local/bin/mise activate zsh)"
