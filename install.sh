#!/bin/bash

TOP_LEVEL_FILES="aliases bashrc fonts fzf.bash fzf.zsh gitconfig gorc tmux.conf vimrc zshrc zshrc.d"

for file in ${TOP_LEVEL_FILES}; do
  if [[ $(readlink -f ~/.${file}) != ${PWD}/${file} ]]; then
    [[ -e ~/.${file} ]] && mv ~/.${file} ~/.${file}.orig
    ln -s ${PWD}/${file} ~/.${file}
  fi
done

ln -s ${PWD}/aliases ~/.bash_aliases

for file in config/*/*; do
  if [[ $(readlink -f ~/.${file}) != ${PWD}/${file} ]]; then
    if [[ -e ~/.${file} ]]; then
      mv ~/.${file} ~/.${file}.orig
    else
      mkdir -p $(dirname ~/.${file})
    fi
    ln -s ${PWD}/${file} ~/.${file}
  fi
done

mkdir -p ~/bin
for file in bin/*; do
  if [[ $(readlink -f ~/${file}) != ${PWD}/${file} ]]; then
    [[ -e ~/.${file} ]] && mv ~/${file} ~/${file}.orig
    ln -s ${PWD}/${file} ~/${file}
  fi
done

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
