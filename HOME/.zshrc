#!/usr/bin/env zsh
# encoding: utf-8
# 
# .zshrc_runner

local RCDIR
RCDIR=$HOME/.zshrc.d

systype=$(uname)

ZSHLOAD_DEBUG=1

for fname in $(ls ${RCDIR}/??_*(^/)); do
    if ! [[ -z "$ZSHLOAD_DEBUG" ]]; then
        print "Processing ${${fname:t}//??_/}"
    fi
    source ${fname}
done

if [[ $systype == "Linux" ]]; then
    export PATH
elif [[ $systype == "Darwin" ]]; then
    export PATH=/opt/local/Library/Frameworks/Python.Framework/Versions/2.6/bin:/usr/bin:/usr/local/bin:/xbin/bin:/usr/bin:/usr/local/bin:/opt/local/bin:$PATH
fi


# Added to incorporate rvm use

if [[ -s "$HOME/.rvm/src/rvm/scripts/rvm" ]]; then
    source "$HOME/.rvm/src/rvm/scripts/rvm";
fi

alias cabal=/usr/local/bin/cabal
export PATH=/usr/local/erlang/bin:$PATH
export PATH=/usr/local/src/narwhal/bin:$PATH
source /usr/local/src/narwhal/bin/activate


function gvim() {
  /usr/bin/gvim 2>|/dev/null 1>|/dev/null "$@" &!
http://github.com/tlrobinson/narwhal.git}

function open() {
  for fname in "$@"; do
    if [[ "${fname:e}" == "html" ]]; then
      chromium-browser "${fname}" 2>/dev/null 1>/dev/null &!
    elif [[ "${fname:e}" == "pdf" ]]; then
       echo "NYI"
    fi
  done
}

      
if [[ "$(hostname)" == 'euler' ]]; then
  export CM="/usr/local/src/connamara/Security-Master"
elif [[ "$(hostname)" == 'thinky' ]]; then
  export CM=/opt/Security-Master
fi

alias -g CB='$(xclip -o -selection clipboard)'
alias -g XSEL='$(xclip -o -selection primary)'

export NARWHAL_HOME=/usr/local/src/narwhal

alias js=/usr/bin/js

alias -s git="git clone "
alias -s html="open "



# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end

PYLINTRC="$HOME/.pylintrc.d/pylintrc"

