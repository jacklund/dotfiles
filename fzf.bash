# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jack/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/jack/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/jack/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/jack/.fzf/shell/key-bindings.bash"
