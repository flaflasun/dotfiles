typeset -U path cdpath fpath manpath
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path

sudo_path=({/usr/local,/usr,}/sbin(N-/))
path=(~/bin(N-/) /usr/local/bin(N-/) ${path})

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

eval "$(rbenv init -)"
eval "$(pyenv init -)"

### Add ~/bin to PATH
export PATH="~/bin:$PATH"

### Added by the JAVA
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Added by the Homebrew
export PATH="/usr/local/sbin:$PATH"

### Added by the golang
export GOPATH=$HOME/go
case ${OSTYPE} in
    darwin*)
        export GOROOT=/usr/local/opt/go/libexec
        ;;
    linux*)
        export GOROOT=/usr/lib/go
        ;;
esac
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
