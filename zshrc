################################################################################
# flaflasun's zshrc
################################################################################
# Environment {{{

export EDITOR=vim
export LC_ALL=en_US.UTF-8
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

# The next line enables shell command completion for gcloud.
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
unsetopt promptcr
setopt transient_rprompt

setopt auto_cd
setopt auto_pushd
setopt correct
setopt pushd_ignore_dups

setopt list_packed
setopt auto_param_slash
setopt mark_dirs
setopt list_types
setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt magic_equal_subst
setopt interactive_comments

setopt complete_in_word
setopt always_last_prompt

setopt print_eight_bit
setopt extended_glob

setopt append_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_nodups
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_expand

setopt brace_ccl
setopt ignore_eof

# }}}

################################################################################
# Alias {{{

case ${OSTYPE} in
  darwin*)
    alias ls='ls -G -w'
    alias gls='gls --color --show-control-chars'
    alias chrome='open -a Google\ Chrome'
    alias vim='env_LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
    alias ggdb='/usr/local/Cellar/gdb/7.9.1/bin/gdb'
    alias ql='qlmanage -p "$@" >& /dev/null'
  ;;
  linux*)
    alias ls='ls --color --show-control-chars'
    alias chrome='google-chrome'
  ;;
esac

alias la='ls -a'
alias lf='ls -f'
alias ll='ls -lh'

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'

alias cvlc='~/Applications/VLC.app/Contents/MacOS/VLC --intf=rc'

alias -s {html,xhtml}=chrome
alias -s {txt,vim}=vim

alias g=google
alias q=qiita
alias gh=github

alias bcup=brew-cask-upgrade

alias -g P='| peco'
alias -g H='| html2text'
alias -g JQ='| jq'

# peco select
alias B='`git branch -a | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`' 
alias R='`git remote | peco --prompt "GIT REMOTE>" | head -n 1`'
alias G='`curl -sL https://api.github.com/users/flaflasun/repos | jq -r ".[].full_name" | peco --prompt "GITHUB REPOS>" | head -n 1`'
alias L='`git log --oneline --branches | peco --prompt "GIT LOG" | awk "{print $1}"`'

alias -g wordcl="wordc -c ',.;()!?<>-+={}[]@#$%^*|\"\`' -d '/_:&'~"

alias lc=peco-ls-cd
alias -g wt=peco-wordc-mstrans
alias fc=peco-find-cd
alias sf=peco-search-file

# google app engine for go
alias goapp=~/google-cloud-sdk/platform/google_appengine/goapp
# }}}

################################################################################
# Keybinds {{{

# emacs keybinds
bindkey -e

bindkey '^R' history-incremental-pattern-search-backward

# ignore keybinds
bindkey -r '^S'

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

function web_search {
  local url=$1       && shift
  local delimiter=$1 && shift
  local prefix=$1    && shift
  local query

  while [ -n "$1" ]; do
    if [ -n "$query" ]; then
      query="${query}${delimiter}${prefix}$1"
    else
      query="${prefix}$1"
    fi
    shift
  done

  open "${url}${query}"
}

function google() {
  web_search "https://www.google.co.jp/search?&q=" "+" "" $@
}

function qiita() {
  web_search "http://qiita.com/search?utf8=✓&q=" "+" "" $@
}

function github() {
  web_search "https://github.com/search?utf8=✓&q=" "+" "" $@
}

function brew-cask-upgrade() {
  for c in `brew cask list`;do
    ! brew cask info $c | grep -qF "Not installed" || brew cask install $c
  done
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
    awk '!a[$0]++' | \
    peco --query $LBUFFER)
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function peco-ls-cd() {
  local dir="$( find . -maxdepth 1 -type d | sed -e 's;\./;;' | peco)"
  if [ ! -z $dir ] ; then
    cd $dir
  fi
}

function peco-wordc-mstrans() {
  if [ -p /dev/stdin ]; then
    text=`cat -`
    local word="$(wordc $text | peco | awk '{ print $1 }')"
    mstrans $word
  fi
}

function peco-search-file() {
  ${1:=$(pwd)}
  local selected=$(find $1 -maxdepth 2 | peco)
  if [[ -d $selected ]]; then
    peco-search-file $selected
  elif [[ -f $selected ]]; then
    cat $selected
  fi
}

function peco-select-ghq() {
  local selected_dir=$(ghq list --full-path | peco)
  if [[ -d $selected_dir ]]; then
    cd $selected_dir
  fi
  zle clear-screen
}
zle -N peco-select-ghq
bindkey '^g' peco-select-ghq

# }}}

################################################################################
# Others {{{

# z
source $(brew --prefix)/etc/profile.d/z.sh
compctl -U -K _z_zsh_tab_completion ${_Z_CMD:-z}
alias j='z'

# Automatically compile zshrc.
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
   zcompile ~/.zshrc
fi

# edit-command-line
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^v' edit-command-line

# Command history setting.
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# }}}
