
# Enable colors and change prompt:
autoload -U colors && colors

NEWLINE=$'\n'
PROMPT="%F{9}┌%f%F{red}─[%f%n%B%F{yellow}@%f%b%B%F{87}%m%f%b%F{9}]%f%F{red}─[%f%F{34}%d%f%F{9}]%f${NEWLINE}%F{9}└──╼ %f%F{11}$%f%b"
#Disable beeping
unset BEEP

#source
source "$ZDOTDIR/zsh-functions"
source "$ZDOTDIR/zsh-exports"
zsh_add_file "zsh-alias"




#Plugins
zsh_add_plugin "conda-incubator/conda-zsh-completion" false
zsh_add_plugin "zsh-users/zsh-autosuggestions"
#zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "sbugzu/gruvbox-zsh"; ZSH_THEME="gruvbox"


#Autocompletions
autoload -Uz compinit
compinit
_comp_options+=(globdots)

# vi mode
bindkey -v
export KEYTIMEOUT=1

#Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

