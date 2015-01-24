################################################################################
# flaflasun's zshrc
################################################################################
# Environment {{{

export EDITOR=vim
export LANG=ja_JP,UTF-8

# Default umask.
umask 022

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

REPORTTIME=3

# less option setting.
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'

# }}}

################################################################################
# Completions {{{

if [ -e /usr/local/share/zsh-completions ]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

# tmuxinator
source ~/.tmuxinator/tmuxinator.zsh

# The next line updates PATH for the Google Cloud SDK.
source ~/google-cloud-sdk/path.zsh.inc

# The next line enables bash completion for gcloud.
source ~/google-cloud-sdk/completion.zsh.inc

autoload -Uz compinit
compinit

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' completer _oldlist _complete _expand _history _list _ignored _approximate _match _prefix
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' verbose yes
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:descriptions' format '%d'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin/ /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ':completion:*' use-cache true
zstyle ':completion:*' group-name ''

# cd search path.
cdpath=($HOME)

# }}}

################################################################################
# Colors {{{

autoload -Uz colors
colors

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export LSCOLORS=ExFxCxdxBxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

autoload -Uz vcs_info
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' max-exports 6
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b@%r' '%c' '%u'
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'
function vcs_echo {
  local st branch color
  STY= LANG=en_US.UTF-8 vcs_info
  st=`git status 2> /dev/null`
  if [[ -z "$st" ]]; then return; fi
  branch="$vcs_info_msg_0_"
  if   [[ -n "$vcs_info_msg_1_" ]]; then color=${fg[green]}
  elif [[ -n "$vcs_info_msg_2_" ]]; then color=${fg[red]}
  elif [[ -n `echo "$st" | grep "^Untracked"` ]]; then color=${fg[blue]}
  else color=${fg[cyan]}
  fi
  echo "%{$color%}(%{$branch%})%{$reset_color%}" | sed -e s/@/"%F{yellow}@%f%{$color%}"/
}

# prompt settings.
local prompt_bar_user='%{${fg[cyan]}%}%n@%m'
local prompt_bar_path='%F{63} [%~]'
local prompt_bar_git=' `vcs_echo`'
local prompt_left='%{${fg[magenta]}%}$SHELL %{${reset_color}%}%# '

PROMPT="${prompt_bar_user}${prompt_bar_path}${prompt_bar_git}"$'\n'"${prompt_left}"
PROMPT2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
RPROMPT="%F{63}[%c]%{${reset_color}%}"
SPROMPT="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

# }}}

################################################################################
# Options {{{

setopt no_beep

setopt no_flow_control

setopt prompt_subst
setopt prompt_percent
setopt transient_rprompt

setopt auto_cd
setopt auto_pushd
setopt correct
setopt pushd_ignore_dups

setopt list_packed
setopt auto_param_slash
setopt mark_dirs
setopt list_types
setopt auto_menu
setopt auto_param_keys
setopt magic_equal_subst
setopt interactive_comments

setopt complete_in_word
setopt always_last_prompt

setopt print_eight_bit
setopt extended_glob

setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_nodups
setopt hist_ignore_space
setopt hist_reduce_blanks

setopt brace_ccl
# }}}

################################################################################
# Alias {{{

case ${OSTYPE} in
  darwin*)
    alias ls="ls -G -w"
    alias gls="gls --color --show-control-chars"
  ;;
  linux*)
    alias ls="ls --color --show-control-chars"
  ;;
esac

alias la="ls -a"
alias lf="ls -f"
alias ll="ls -lh"

alias mvi="mvim --remote-tab-silent"

alias cvlc='~/Applications/VLC.app/Contents/MacOS/VLC --intf=rc'

if [ 'uname' = "Darwin" ]; then
  alias chrome='open -a Google\ Chrome'
elif [ 'uname' = "Linux" ]; then
  alias chrome='google-chrome'
fi
alias -s {html,xhtml}=chrome

alias -s {txt,vim}=mvim

# peco select git
alias -g B='`git branch -a | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`' 
alias -g R='`git remote | peco --prompt "GIT REMOTE>" | head -n 1`'
alias -g H='`curl -sL https://api.github.com/users/flaflasun/repos | jq -r ".[].full_name" | peco --prompt "GITHUB REPOS>" | head -n 1`'

# google app engine for go
alias goapp=~/google-cloud-sdk/platform/google_appengine/goapp
# }}}

################################################################################
# Keybinds {{{

# emacs keybinds
bindkey -e

bindkey '^R' history-incremental-pattern-search-backward

#}}}

################################################################################
# Functions {{{

function extract() {
  case $1 in
    *.bz2) bzip2 -dc $1;;
    *.gz) gzip -d $1;;
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.tar) tar xvf $1;;
    *.zip) unzip $1;;
    *.Z) uncompress $1;;
  esac
}
alias -s {bz2,gz,tar,tbz,tgz,zip,Z}=extract

function chpwd() {
    ls_abbrev
}
function ls_abbrev() {
  if [[ ! -r $PWD ]]; then
    return
  fi
  # -a : Do not ignore entries starting with ..
  # -C : Force multi-column output.
  # -F : Append indicator (one of */=>@|) to entries.
  local cmd_ls='ls'
  local -a opt_ls
  opt_ls=('-aCF' '--color=always')
  case "${OSTYPE}" in
    freebsd*|darwin*)
      if type gls > /dev/null 2>&1; then
          cmd_ls='gls'
      else
          # -G : Enable colorized output.
          opt_ls=('-aCFG')
      fi
    ;;
  esac

  local ls_result
  ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

  local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

  if [ $ls_lines -gt 10 ]; then
    echo "$ls_result" | head -n 5
    echo '...'
    echo "$ls_result" | tail -n 5
    echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
  else
    echo "$ls_result"
  fi
}

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# }}}

################################################################################
# Others {{{

# z
source $(brew --prefix)/etc/profile.d/z.sh
compctl -U -K _z_zsh_tab_completion ${_Z_CMD:-z}
alias j='z'

# Command history setting.
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# }}}