. /etc/os-release || {
    log_error "Failed to source /etc/os-release"
    exit 1
}

log_info() {
    local message="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - \033[32mINFO: $message\033[0m" >&2
}

log_error() {
    local message="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - \033[31mERROR: $message\033[0m" >&2
}

detect_sudo_tool() {
    if [ $(id -u) -eq 0 ]; then
        echo ""
        log_info "Running as root, no sudo tool required."
    else
        if command -v sudo &> /dev/null; then
            echo "sudo"
        elif command -v doas &> /dev/null; then
            echo "doas"
        else
            log_error "No sudo tool found. Please install sudo or doas."
            exit 1
        fi
    fi
}


detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt-get"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        log_error "No supported package manager found."
        exit 1
    fi
}

debian12_install_fastfetch() {
    local arch package_name url sudo_tool
    arch=$(uname -m)

    case "$arch" in
        x86_64)   package_name="fastfetch-linux-amd64.deb" ;;
        aarch64)  package_name="fastfetch-linux-aarch64.deb" ;;
        armv7l)   package_name="fastfetch-linux-armv7l.deb" ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac

    log_info "Fetching latest Fastfetch release for $arch..."
    url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep browser_download_url | cut -d\" -f4 | grep "$package_name")

    if [ -z "$url" ]; then
        log_error "Failed to retrieve the download URL for $package_name"
        return 1
    fi

    log_info "Downloading $package_name..."
    if ! curl -LSso "/tmp/$package_name" "$url"; then
        log_error "Download failed for $package_name"
        return 1
    fi

    sudo_tool=$(detect_sudo_tool)
    log_info "Installing $package_name..."
    if ! ${sudo_tool} apt-get install "/tmp/$package_name" -y; then
        log_error "Installation failed for $package_name"
        return 1
    fi

    log_info "Fastfetch installed successfully!"
}

install_packages() {
    log_info "Installing required packages..."

    local sudo_tool
    sudo_tool=$(detect_sudo_tool)

    case $ID in 
        debian)
            if [ "$VERSION_ID" = "12" ]; then
                debian12_install_fastfetch
            else
                apt-get install -y fastfetch
            fi
            ;;
        ubuntu)
            if [ "$VERSION_ID" = "24.04" ]; then
                debian12_install_fastfetch
            else
                apt-get install -y fastfetch
            fi
            ;;
    esac


    # Install other common packages
    local packages=("zsh" "git" "curl" "zoxide" "unzip" "jq")
    log_info "Installing common packages: ${packages[*]}"

    case $(detect_package_manager) in
        apt-get)
            $sudo_tool apt-get update && apt-get install -y "${packages[@]}"
            ;;
        pacman)
            $sudo_tool pacman -Sy --noconfirm --needed "${packages[@]}"
            ;;
        yum)
            $sudo_tool yum install -y "${packages[@]}"
            ;;
        apk)
            $sudo_tool apk add "${packages[@]}"
            ;;
        *)
            log_error "Unsupported package manager for installing common packages."
            exit 1
            ;;
    esac

    



}

main() {

    log_info "Installer downloaded successfully. Starting installation..."



    install_packages

    mkdir -p "$HOME/.local/bin"
    export PATH="$PATH:$HOME/.local/bin"

    download_file https://ohmyposh.dev/install.sh /dev/stdout | bash -s -- -d ~/.local/bin
    mkdir -p ~/.cache


    mkdir -p "$DSTPATH"

    # Install Oh My Zsh if not already installed
    if [ ! -d "$DSTPATH/oh-my-zsh" ]; then
        download_file https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh /tmp/OhMyZsh.sh
        chmod +x /tmp/OhMyZsh.sh
        ZSH="$DSTPATH/oh-my-zsh" /tmp/OhMyZsh.sh --unattended
        rm /tmp/OhMyZsh.sh
    fi


    # Download configuration files
    download_file "$BASEURL/theme.omp.json" "$DSTPATH/theme.omp.json"
    download_file "$BASEURL/zshrc" "$DSTPATH/zshrc"
    download_file "$BASEURL/latest_version" "$DSTPATH/version"
    

cat <<EOF > "$HOME/.zshrc"
INSTALLBASE=$DSTPATH
BASEURL="$BASEURL"
EOF

    declare -f log_info >> "$HOME/.zshrc"
    declare -f log_error >> "$HOME/.zshrc"

    echo "source $DSTPATH/zshrc" >> "$HOME/.zshrc"

    # Change default shell to Zsh
    chsh -s $(which zsh)

}