#!/bin/bash

BASEURL="https://zsh.onlh.de/"

if [ -z "$HOME" ]; then
    echo "Your \$HOME is empty, can't continue!"
    exit 1
fi

DSTPATH="$HOME/.lhzsh"

install_fastfetch_deb() {
    # Determine system architecture
    arch=$(uname -m)
    package_name=""

    # Define the package name based on the architecture
    case $arch in
    x86_64)
        package_name="fastfetch-linux-amd64.deb"
        ;;
    aarch64)
        package_name="fastfetch-linux-aarch64.deb"
        ;;
    armv7l)
        package_name="fastfetch-linux-armv7l.deb"
        ;;
    *)
        echo "Unsupported architecture: $arch"
        return 1
        ;;
    esac

    # Fetch the latest release URL for the appropriate package
    url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep browser_download_url | cut -d\" -f4 | grep "$package_name")

    # Check if the URL was successfully retrieved
    if [ -z "$url" ]; then
        echo "Failed to retrieve the download URL for $package_name"
        return 1
    fi

    # Download the correct .deb file
    curl -LSso /tmp/$package_name $url
    if [ $? -ne 0 ]; then
        echo "Download failed for $package_name"
        return 1
    fi

    # Install the package using apt
    apt-get install /tmp/$package_name -y
    if [ $? -ne 0 ]; then
        echo "Installation failed for $package_name"
        return 1
    fi

    echo "Installation successful!"
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
        echo "unsupported"
    fi
}

install_packages() {
    package_manager=$(detect_package_manager)
    case $package_manager in
    apt-get)
        apt-get update
        install_fastfetch_deb
        apt-get install zsh git curl zoxide unzip jq -y
        ;;
    pacman)
        pacman -Syu zsh git curl fastfetch zoxide unzip jq --noconfirm
        ;;
    yum)
        yum install zsh git curl fastfetch unzip jq -y
        ;;
    apk)
        apk add zsh git curl shadow zoxide fastfetch unzip jq
        ;;
    *)
        echo "No supported package manager found."
        echo "Required packages: zsh git fastfetch zoxide"
        exit 1
        ;;
    esac
}

cleanup_old_zsh() {
    echo "Hello There!"
    echo "It seems like you have a pre-rewrite version of my ZSH config."
    echo "To install the rewrite, I need to clean some stuff up. THIS WILL DELETE ANY ZSH RELATED STUFF!"
    echo -n "Would you like to continue? (y/N): "
    read response
    if [[ "$response" =~ ^[yY]$ ]]; then
        echo "Proceeding with cleanup..."
        rm -rf ~/.zshrc ~/.zshrc.d ~/.oh-my-zsh ~/.p10k.zsh ~/.lhzshver ~/.config/neofetch

        package_manager=$(detect_package_manager)
        case $package_manager in
        apt-get)
            apt-get remove --purge -y cowsay fortunes fortunes-de fortunes-min lolcat neofetch
            apt-get autoremove -y
            ;;
        pacman)
            pacman -Rns --noconfirm cowsay fortune-mod lolcat neofetch
            ;;
        yum)
            yum remove -y cowsay fortune-mod lolcat neofetch
            ;;
        apk)
            apk del neofetch
            ;;
        *)
            echo "No supported package manager found."
            exit 1
            ;;
        esac
    else
        echo "\n\nAborted cleanup. Installation will *NOT* proceed."
        echo "If you are coming from pre v1.0.0, please manually update by typing:"
        echo "\nbash <(curl https://cdn.onlh.de/zsh.sh)"
        exit 0
    fi
}

main() {
    if [ -f ~/.lhzshver ] || [ -d ~/.zshrc.d ]; then
        cleanup_old_zsh
    fi

    mkdir -p "$HOME/.local/bin"
    export PATH="$PATH:$HOME/.local/bin"

    # Install required packages
    install_packages && clear

    # Install Oh My Posh
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
    mkdir -p ~/.cache

    # Install Oh My Zsh if not already installed
    if [ ! -d "$DSTPATH/oh-my-zsh" ]; then
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/OhMyZsh.sh
        chmod +x /tmp/OhMyZsh.sh
        ZSH="$DSTPATH/oh-my-zsh" /tmp/OhMyZsh.sh --unattended
        rm /tmp/OhMyZsh.sh
    fi

    mkdir -p "$DSTPATH"

    # Download configuration files
    curl -s "$BASEURL/theme.omp.json" -o "$DSTPATH/theme.omp.json"
    curl -s "$BASEURL/zshrc" -o "$HOME/.zshrc"
    curl -s "$BASEURL/latest_version" | jq -r '.[0].sha' > "$DSTPATH/version"

    # Change default shell to Zsh
    chsh -s $(which zsh)

    clear

    echo "Thank you for choosing Leon's ZSH Config."
    echo "Have an awesome day!"
}

main
