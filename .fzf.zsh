# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ins/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/ins/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/ins/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/ins/.fzf/shell/key-bindings.zsh"
