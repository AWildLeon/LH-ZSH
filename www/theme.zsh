autoload -U colors && colors
setopt prompt_subst

COLOR_USER="#CCCCCC"
COLOR_HOST="#6A6A6A"
COLOR_PATH="#004e8e"
COLOR_SYMBOL="#CC00CC"
COLOR_ERROR="#FF0000"

my_custom_prompt_precmd() {
    local exit_code=$?
    
    local symbol_color="$COLOR_SYMBOL"
    if [[ $exit_code -ne 0 ]]; then
        symbol_color="$COLOR_ERROR"
    fi

    PROMPT="%F{$COLOR_USER}${USER:-$(whoami)}%f%F{$COLOR_HOST}@${HOST%%.*} %f%F{$COLOR_PATH}%~ %f
%F{$symbol_color}❯ %f"
    
    print -Pn "\e]0;%~\a"
}

autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook precmd my_custom_prompt_precmd

typeset -gi TRANSIENT_PROMPT_FD=-1
TRANSIENT_PROMPT_SYMBOL="%F{$COLOR_SYMBOL}❯ %f"
zmodload -F zsh/system b:sysopen 2>/dev/null

_transient_prompt_restore() {
    if (( TRANSIENT_PROMPT_FD != -1 )); then
        zle -F "$TRANSIENT_PROMPT_FD"
        exec {TRANSIENT_PROMPT_FD}<&-
        TRANSIENT_PROMPT_FD=-1
    fi

    my_custom_prompt_precmd
    zle reset-prompt
}

_transient_prompt_schedule_restore() {
    if (( TRANSIENT_PROMPT_FD == -1 )) && (( $+builtins[sysopen] )); then
        sysopen -ru TRANSIENT_PROMPT_FD /dev/null || TRANSIENT_PROMPT_FD=-1
        (( TRANSIENT_PROMPT_FD != -1 )) && zle -F "$TRANSIENT_PROMPT_FD" _transient_prompt_restore
    fi
}

_transient_prompt_collapse_current() {
    PROMPT="${TRANSIENT_PROMPT_SYMBOL}"
    RPROMPT=""
    zle reset-prompt
    _transient_prompt_schedule_restore
}

_transient_prompt_line_finish() {
    _transient_prompt_collapse_current
}

add-zle-hook-widget line-finish _transient_prompt_line_finish

for keymap in emacs viins vicmd; do
    [[ -n "${terminfo[khome]}" ]] && bindkey -M "$keymap" "${terminfo[khome]}" beginning-of-line
    [[ -n "${terminfo[kend]}" ]]  && bindkey -M "$keymap" "${terminfo[kend]}" end-of-line

    bindkey -M "$keymap" '^[[H'  beginning-of-line
    bindkey -M "$keymap" '^[[1~' beginning-of-line
    bindkey -M "$keymap" '^[[7~' beginning-of-line
    bindkey -M "$keymap" '^[OH'  beginning-of-line

    bindkey -M "$keymap" '^[[F'  end-of-line
    bindkey -M "$keymap" '^[[4~' end-of-line
    bindkey -M "$keymap" '^[[8~' end-of-line
    bindkey -M "$keymap" '^[OF'  end-of-line
done

my_custom_prompt_precmd
