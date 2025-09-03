#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

BASEURL="https://zsh.onlh.de"
PROJECTNAME="INSERT-PROJECT-NAME"

if [ -z "$HOME" ]; then
    echo "Your \$HOME is empty, can't continue!"
    exit 1
fi

DSTPATH="$HOME/.lhzsh"

#GHA-REMOVE-BEGIN
# Load debug stuff if it exists
if [[ -f "./.debug" ]]; then
    source "./.debug"
fi 
#GHA-REMOVE-END

echo "Downloading and running the $PROJECTNAME installation script..."

download_file() {
    # This function downloads a file using curl or any other method
    local url="$1"
    local output="$2"
    if command -v curl > /dev/null; then
        curl -Ls -o "$output" "$url"
    elif command -v wget > /dev/null; then
        wget -O "$output" "$url"
    elif command -v fetch > /dev/null; then
        fetch -o "$output" "$url"
    else
        echo "No download tool found (curl, wget, fetch). Please install one of them."
        exit 1
    fi
}

source <(download_file "${BASEURL}/installer.sh" /dev/stdout)
main && echo "Installation completed successfully!" || echo "Installation failed."
