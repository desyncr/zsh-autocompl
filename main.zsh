# vim: sw=2 ts=2 et!
#zmodload zsh/zle
# expand-or-complete-or-list-files
INCR_MIN_LENGTH=${INCR_MIN_LENGTH:-2}
INCR_MAX_LENGTH=${INCR_MAX_LENGTH:-10}
INCR_MAX_MATCHES=${INCR_MAX_MATCHES:-100}

function complete-files-func () { compadd -- $(command ls .) }
zle -C complete-files complete-word complete-files-func

path+=(${0:A:h}/zsh-capture-completion/)
if (( $+commands[capture.zsh] )); then
  USE_CAPTURE=true
  function complete-args-func () { compadd -- ${$(capture.zsh "$BUFFER")//$'\r'} }
  zle -C complete-args complete-word complete-args-func
fi

function limit-completion () {
   local list_lines
   list_lines=$compstate[list_lines]
   if [[ "$list_lines" -gt $INCR_MAX_MATCHES ]]
   then
      compstate[list]=''
      zle -M "Too many matches."
   elif [[ "$list_lines" == 0 ]]; then
      compstate[list]=''
   fi
}

function zle-autosuggestion () {
  zle self-insert
  [[ $#BUFFER -lt $INCR_MIN_LENGTH || $#BUFFER -gt $INCR_MAX_LENGTH || $BUFFER =~ "'" || $BUFFER =~ '"' ]] && { zle -M ''; return }

  [[ $BUFFER = l* ]] && zle complete-files
  [[ $USE_CAPTURE == true && "$BUFFER" =~ -$ ]] && zle complete-args
  comppostfuncs=(limit-completion)

  zle list-choices
}


zle -N zle-autosuggestion
for key in {a..z}; do
  bindkey $key zle-autosuggestion
done

bindkey '\-' zle-autosuggestion

