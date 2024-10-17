# WARNING:
# THIS FILE IS MANAGED BY LH ZSH
# MODIFICATIONS WILL ONLY STAY TILL THE NEXT UPDATE!

LHZSH_INSTBASE=$HOME/.lhzsh
LHZSH_BASEURL=https://cdn.onlh.de/zsh

# Source custom start script if it exists
if [ -f ~/.lhzsh.custom/start.zsh ]; then
    source ~/.lhzsh.custom/start.zsh
fi

if [ -z "$NOTRECOMENDED_DONTUPDATE" ]; then

    # Fetch local version
    local_ver=$(cat $LHZSH_INSTBASE/version 2>/dev/null)

    # Attempt to fetch the remote version
    remote_ver=$(curl -fsm 1 $LHZSH_BASEURL/version)
    curl_exit_code=$?

    # Proceed if curl was successful and versions do not match
    if [ $curl_exit_code -eq 0 ] && [ "$local_ver" != "$remote_ver" ]; then
        curl -fs $LHZSH_BASEURL/changelog.txt
        echo -e "A new version of Leon's zsh Config is available.\nThis will delete any custom configuration.\nWould you like to update? (Y/n)"
        read -r response
        if [ -z "$response" ] || [[ $response =~ ^[Yy] ]]; then
            echo "Updating lhzsh to version $remote_ver"
            bash <(curl $LHZSH_BASEURL/zsh.sh)
            zsh
            exit 0
        else
            echo "Update canceled."
        fi
    elif [ $curl_exit_code -ne 0 ]; then
        # Output an error if curl failed but don't exit
        echo "WARN: Update Check failed!"
    fi

    # Unset variables to clean up the environment
    unset local_ver remote_ver curl_exit_code response

fi

export PATH=$PATH:$HOME/.local/bin

# Path to your oh-my-zsh installation.
export ZSH="$LHZSH_INSTBASE/oh-my-zsh"

# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 30

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

if [ -f /etc/arch-release ]; then
    DISTROPLUGIN=archlinux
elif command -v dnf >/dev/null; then
    DISTROPLUGIN=dnf
elif [ -f /etc/debian_version ]; then
    DISTROPLUGIN=debian
fi

plugins=(git docker docker-compose systemd vscode zoxide "$DISTROPLUGIN")

# Source custom plugins script if it exists
if [ -f ~/.lhzshrc.custom/plugins.zsh ]; then
    source ~/.lhzshrc.custom/plugins.zsh
fi

source $ZSH/oh-my-zsh.sh

# Prompt Engine
eval "$(oh-my-posh init zsh --config $LHZSH_INSTBASE/theme.omp.json)"

alias cd=z

# Greet
if [[ -o interactive ]]; then
    # clear
    # echo "Netzwerk"
    # echo "========"
    # ip addr show | awk '/inet / && !/ lo| docker| br-/ {print $2 " " $NF}'
    echo
    fastfetch
fi

# Source custom end script if it exists
if [ -f ~/.lhzshrc.custom/end.zsh ]; then
    source ~/.lhzshrc.custom/end.zsh
fi

# Cleanup Env
unset LHZSH_INSTBASE LHZSH_BASEURL

# WARNING:
# THIS FILE IS MANAGED BY LH ZSH
# MODIFICATIONS WILL ONLY STAY TILL THE NEXT UPDATE!
