typeset -U path cdpath fpath manpath
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path

sudo_path=({/usr/local,/usr,}/sbin(N-/))
path=(~/bin(N-/) /usr/local/bin(N-/) ${path})

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

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

### Added by the Ruby
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

### Added by the Python
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
export PATH="$PYENV_ROOT/versions/anaconda3-4.3.1/bin/:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
