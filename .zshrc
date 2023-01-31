# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/ins/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="alanpeabody"

plugins=(
    git
    history-substring-search
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    web-search
    copyfile
    copybuffer
    dirhistory
    jsontools
)

source $ZSH/oh-my-zsh.sh
source /home/ins/.oh-my-zsh/custom/themes/powerlevel10k
source /home/ins/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Usaado somentee em maquiinas fisicas com linux 
#setxkbmap -model pc104 -layout us_intl

######################################################################################################################################### alias personalizados

## apps abreviados
alias ls="ls -la"

## export krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

##############################################################################################################   app instalados

# fdfind conf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fdfind --type f'
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info --height=80%"

# AWSP
source ~/awsp_functions.sh
alias awsall="_awsListProfile"
alias awsp="_awsSetProfile"
alias awswho="aws configure list"
complete -W "$(cat $HOME/.aws/credentials | grep -Eo '\[.*\]' | tr -d '[]')" _awsSwitchProfile
complete -W "$(cat $HOME/.aws/config | grep -Eo '\[.*\]' | tr -d '[]' | cut -d " " -f 2)" _awsSetProfile

# asdf
#. /opt/asdf-vm/asdf.sh
. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit


# Invert o terminal para ficar sempre para baixo 
print ${(pl:$LINES::\n:):-}

##########################################################################################################################################
