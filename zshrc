autoload -U compinit
compinit

autoload -U colors
colors

autoload -U select-word-style
select-word-style bash

# If using tmux, Disable bracketed paste
[[ -n "$TMUX" ]] && unset zle_bracketed_paste

test -e $HOME/.nvm/nvm.sh && . $HOME/.nvm/nvm.sh

git_user() {
  user=$(git -C "$1" config user.name)
  author=$(git -C "$1" config duet.env.git-author-initials)
  committer=$(git -C "$1" config duet.env.git-committer-initials)

  if [ -n "${committer}" ]; then
    echo "${author} & ${committer}%{$fg[black]%}@%{$reset_color%}"
  elif [ -n "${author}" ]; then
    echo "${author}%{$fg[black]%}@%{$reset_color%}"
  elif [ -z $user ]; then
    echo "%{$fg_bold[red]%}no user%{$fg[black]%}@%{$reset_color%}"
  else
    echo "$user%{$fg[black]%}@%{$reset_color%}"
  fi
}

git_root() {
  local folder='.'
  for i in $(seq 0 $(pwd|tr -cd '/'|wc -c)); do
    [ -d "$folder/.git" ] && echo "$folder" && return
    folder="../$folder"
  done
}

git_branch() {
  local git_root="$1"
  local line="$2"
  local branch="???"
  local ahead=''
  local behind=''

  case "$line" in
    \#\#\ HEAD*)
      branch="$(git -C "$git_root" tag --points-at HEAD)"
      [ -z "$branch" ] && branch="$(git -C "$git_root" rev-parse --short HEAD)"
      branch="%{$fg[yellow]%}${branch}%{$reset_color%}"
      ;;
    *)
      branch="${line#\#\# }"
      branch="%{$fg[green]%}${branch%%...*}%{$reset_color%}"
      ahead="$(echo $line | sed -En -e 's|^.*(\[ahead ([[:digit:]]+)).*\]$|\2|p')"
      behind="$(echo $line | sed -En -e 's|^.*(\[.*behind ([[:digit:]]+)).*\]$|\2|p')"
      [ -n "$ahead" ] && ahead="%{$fg_bold[white]%}↑%{$reset_color%}$ahead"
      [ -n "$behind" ] && behind="%{$fg_bold[white]%}↓%{$reset_color%}$behind"
      ;;
  esac

  print "${branch}${ahead}${behind}"
}

git_status() {
  local untracked=0
  local modified=0
  local deleted=0
  local staged=0
  local branch=''
  local output=''

  for line in "${(@f)$(git -C "$1" status --porcelain -b 2>/dev/null)}"
  do
    case "$line" in
      \#\#*) branch="$(git_branch "$1" "$line")" ;;
      \?\?*) ((untracked++)) ;;
      U?*|?U*|DD*|AA*|\ M*|\ D*) ((modified++)) ;;
      ?M*|?D*) ((modified++)); ((staged++)) ;;
      ??*) ((staged++)) ;;
    esac
  done

  output="$branch"

  [ $staged -gt 0 ] && output="${output} %{$fg_bold[green]%}S%{$fg_no_bold[black]%}:%{$reset_color$fg[green]%}$staged%{$reset_color%}"
  [ $modified -gt 0 ] && output="${output} %{$fg_bold[red]%}M%{$fg_no_bold[black]%}:%{$reset_color$fg[red]%}$modified%{$reset_color%}"
  [ $deleted -gt 0 ] && output="${output} %{$fg_bold[red]%}D%{$fg_no_bold[black]%}:%{$reset_color$fg[red]%}$deleted%{$reset_color%}"
  [ $untracked -gt 0 ] && output="${output} %{$fg_bold[yellow]%}?%{$fg_no_bold[black]%}:%{$reset_color$fg[yellow]%}$untracked%{$reset_color%}"

  echo "$output"
}

git_prompt_info() {
  local GIT_ROOT="$(git_root)"
  [ -z "$GIT_ROOT" ] && return

  print " $(git_user "$GIT_ROOT")$(git_status "$GIT_ROOT") "
}

simple_git_prompt_info() {
  ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
  user=$($(which git) config user.name 2> /dev/null)
  echo " (${user}@${ref#refs/heads/})"
}

ghe_show() {
  sha=`if [ -z $1 ]; then; git log --format=format:"%H" | head -n 1; else; echo $1; fi`
  repo=`git remote -v | grep fetch | grep --only-matching 'github.braintreeps.com:.* ' | sed -e 's/\s$//' -e 's/:/\//' -e 's/.git$//'`
  echo "https://$repo/commit/$sha"
}

job_info() {
  JOB_COUNT="$(jobs | wc -l | tr -d '[:blank:]')"
  if [ "$JOB_COUNT" = "0" ]
  then
    printf ''
  else
    printf ' (%s)' "$JOB_COUNT"
  fi
}

set -o emacs
setopt prompt_subst
setopt HIST_IGNORE_DUPS
export HISTSIZE=200
export HISTFILE=~/.zsh_history
export SAVEHIST=200

export LOCALE="en_US.UTF-8"
export LANG="en_US.UTF-8"

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export PROMPT='%{$fg_bold[green]%}%m:%{$fg_bold[blue]%}%~%{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}%#%{$fg_bold[gray]%}$(job_info)%{$reset_color%} '

export EDITOR=nvim
export LESS='XFR'

export PATH=$HOME/bin:$PATH

# Turn off the dumb-ass ls quotes
export QUOTING_STYLE=literal

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line
bindkey '^i' expand-or-complete-prefix

bindkey '^u' backward-kill-line

stty stop undef
stty start undef

[[ -s ~/.git.plugin.zsh ]] && source ~/.git.plugin.zsh
source ~/.aliases

[[ -s ~/.zshrc_personal ]] && source ~/.zshrc_personal

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

function tmux-start {
  local session=$1
  [ -z "$session" ] && session=`whoami`
  tmux -S /tmp/$session new-session -s $session -d
  chmod 777 /tmp/$session
  tmux -S /tmp/$session attach -t $session
}

function tmux-join {
  local session=$1
  [ -z "$session" ] && session="pair"
  tmux -S /tmp/$1 new-session -t $1
}

function tmux-start-cc {
  local session=$1
  [ -z "$session" ] && session=`whoami`
  tmux -S /tmp/$session new-session -s $session -d
  chmod 777 /tmp/$session
  tmux -S /tmp/$session -CC attach -t $session
}

function tmux-join-cc {
  local session=$1
  [ -z "$session" ] && session="pair"
  tmux -S /tmp/$1 -CC new-session -t $1
}

function tmux-list {
  ps -eo ruser,command | grep '[n]ew-session -s' | ruby -ne '$_ =~ /^(\w+).*-s (\w+)/; puts "#{$1} started #{$2}"'
}

function tmux-watch {
  local session=$1
  [ -z "$session" ] && session="pair"
  tmux -S /tmp/$1 attach -t $1 -r
}

function tag-list {
  git tag --list | sort --version-sort
}

function external-ip {
  curl http://ipecho.net/plain; echo
}

function external-dns {
  dig +noall +answer geekheads.net | awk '{print $5}'
}

mkdir -p ~/.zshrc.d
for file in $(find ~/.zshrc.d -type f -or -type l) ; do
  source "$file"
done

source ~/.gorc

# This makes Control+U delete all characters before the cursor
bindkey \^U backward-kill-line

# This makes Control+W delete a whole word backwards, but stopping at forward slashes
# Shamelessly stolen from: https://unix.stackexchange.com/a/250700
my-backward-kill-word() {
    local WORDCHARS=${WORDCHARS/\//}
    zle backward-kill-word
}
zle -N my-backward-kill-word
bindkey '^W' my-backward-kill-word

# gist configuration
export GITHUB_URL="https://github.com/"

source ~/.cargo/env

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# For systemd user mode
export XDG_RUNTIME_DIR="/run/user/$UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
