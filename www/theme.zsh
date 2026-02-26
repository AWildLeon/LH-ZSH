autoload -U colors && colors
setopt prompt_subst

# Only set up Git integration if Git is actually installed on this machine.
if (( $+commands[git] )); then
    autoload -Uz vcs_info
    # Turn on the git module
    zstyle ':vcs_info:*' enable git
    
    # Enable checking for (un)staged changes
    zstyle ':vcs_info:*' check-for-changes true
    # Set the dirty string to an asterisk
    zstyle ':vcs_info:*' stagedstr '*'
    zstyle ':vcs_info:*' unstagedstr '*'
    
    # Format the git info: " - (branch_name*)" in green.
    # %u is unstaged changes, %c is staged changes
    zstyle ':vcs_info:git:*' formats '- %F{green}(%b%u%c)%f'
    zstyle ':vcs_info:git:*' actionformats '- %F{green}(%b|%a%u%c)%f'
fi

# Our color palette
COLOR_USER="#CCCCCC"
COLOR_HOST="#6A6A6A"
COLOR_PATH="#004e8e"
COLOR_SYMBOL="#CC00CC"
COLOR_ERROR="#FF0000"
COLOR_JOBS="#FFFF00"

# Symbols we use in the prompt
SYMBOL_PROMPT="❯" # The arrow ❯
SYMBOL_JOBS="✦"         # The star for background jobs

# This function runs every time BEFORE the prompt is displayed.
# We use it to calculate dynamic things like git status, errors, etc.
# Renamed to a unique function name to avoid conflicts with other plugins/OMZ
my_custom_prompt_precmd() {
    # Capture the exit code of the LAST command right away.
    local exit_code=$?
    
    # If we have git set up, ask vcs_info what the status is.
    local git_part=""
    if (( $+functions[vcs_info] )); then
        vcs_info
        git_part="${vcs_info_msg_0_}"
    fi

    # Build the first part: "user@host ~/path"
    # %n = username, %m = hostname, %~ = path (shortened with ~)
    local user_part="%F{$COLOR_USER}%n%f"
    local host_part="%F{$COLOR_HOST}@%m %f"
    local path_part="%F{$COLOR_PATH}%~ %f"


    # Build the prompt symbol (❯)
    # If the last command failed (exit code != 0), we turn it RED.
    local current_symbol_color="$COLOR_SYMBOL"
    if [[ $exit_code -ne 0 ]]; then
        current_symbol_color="$COLOR_ERROR"
    fi
    local symbol_part="%F{$current_symbol_color}${SYMBOL_PROMPT} %f"

    # Background Jobs Indicator
    # We use a Zsh trick "%(1j.TRUE.FALSE)" to show the star only if jobs > 0.
    local jobs_indicator="%(1j. %F{$COLOR_JOBS}${SYMBOL_JOBS}%j%f.)"

    # Line 1: user@host path - (git) star
    # Line 2: ❯ 
    PROMPT="${user_part}${host_part}${path_part}${git_part}${jobs_indicator}
${symbol_part}"

    # Make sure we don't have a right-side prompt hanging around.
    RPROMPT=""
    
    # Set the terminal window title to the current folder.
    print -Pn "\e]0;%~\a"
}

# Hook our function into the Zsh precmd array
# This ensures it runs alongside other plugins (like syntax highlighting)
# instead of overwriting them.
autoload -Uz add-zsh-hook
add-zsh-hook precmd my_custom_prompt_precmd

# ------------------------------------------------------------------
# Transient Prompt Magic (Clean History)
# ------------------------------------------------------------------
# When you press ENTER to run a command, this function kicks in.
# It replaces the big, detailed prompt with just a simple "❯" symbol.
# This keeps your terminal history looking super clean!
function zle-line-finish {
    # If we are in the middle of a search (Ctrl+R), don't mess with the prompt.
    if [[ $WIDGET == "zle-isearch-update" || $WIDGET == "zle-isearch-exit" ]]; then 
        return
    fi

    # The simple "Transient" prompt: Just the colored arrow.
    local transient_symbol="%F{$COLOR_SYMBOL}${SYMBOL_PROMPT} %f"
    
    # Swap the prompt for the simple one right before the command runs.
    PROMPT="${transient_symbol}"
    
    # Redraw the line so you see the change immediately.
    zle reset-prompt
}

# When the command finishes and we are ready for a NEW prompt...
# This function restores the full, detailed prompt again.
function zle-line-init {
    # Call our main setup function to rebuild the full PROMPT variable.
    my_custom_prompt_precmd
    # Tell Zsh to use the new (full) prompt.
    zle reset-prompt
}

# Tell Zsh to use these special functions we just wrote.
zle -N zle-line-finish
zle -N zle-line-init

# Start everything up!
my_custom_prompt_precmd

