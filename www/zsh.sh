BASEURL="https://zsh.onlh.de/"

if test -z "$HOME"; then
    echo your \$HOME is empty, can\'t continue!
    exit 1
fi


DSTPATH=$HOME/.lhzsh

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
    apt-get install /tmp/$package_name
    if [ $? -ne 0 ]; then
        echo "Installation failed for $package_name"
        return 1
    fi

    echo "Installation successful!"
}

install_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        install_fastfetch_deb
        apt-get install zsh git curl zoxide unzip -y

    elif command -v pacman >/dev/null 2>&1; then
        pacman -Syu zsh git curl fastfetch zoxide unzip --noconfirm
    elif command -v yum >/dev/null 2>&1; then
        yum install zsh git curl fastfetch unzip -y
    elif command -v apk >/dev/null 2>&1; then
        apk add zsh git curl shadow zoxide fastfetch unzip
    else
        echo "No supported package manager found."
        echo "Req: zsh git fastfetch zoxide"
        exit 1
    fi

}

if [ -f ~/.lhzshver ] || [ -d ~/.zshrc.d ]; then
    echo "Hello There!"
    echo "Seems like you have a Pre-rewrite Version of my ZSH Config."
    echo "To install the rewrite, I need to clean some stuff up. THIS WILL DELETE ANY ZSH RELATED STUFF!"
    echo -n "Would you like to continue? (y/N): "
    read response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        # Place your cleanup and installation commands here
        echo "Proceeding with cleanup..."
        rm -rf ~/.zshrc ~/.zshrc.d ~/.oh-my-zsh ~/.p10k.zsh ~/.lhzshver ~/.config/neofetch

        # Try to Remove old packages
        if command -v apt-get >/dev/null 2>&1; then
            apt-get remove --purge -y cowsay fortunes fortunes-de fortunes-min lolcat neofetch
            apt-get autoremove -y
        elif command -v pacman >/dev/null 2>&1; then
            pacman -Rns --noconfirm cowsay fortune-mod lolcat neofetch
        elif command -v yum >/dev/null 2>&1; then
            yum remove -y cowsay fortune-mod lolcat neofetch
        elif command -v apk >/dev/null 2>&1; then
            apk del neofetch
        else
            echo "No supported package manager found."
            exit 1
        fi

    else
        echo
        echo
        echo "Aborted cleanup. installation will *NOT* proceed."
        echo "if you are coming from pre v1.0.0, please manualy update by typing:"
        echo
        echo "bash <(curl https://cdn.onlh.de/zsh.sh)"
        exit 0
    fi
fi

mkdir -p $HOME/.local/bin
export PATH=$PATH:$HOME/.local/bin

# Requrements
install_packages && clear

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
mkdir -p ~/.cache


if [ ! -d "$DSTPATH/oh-my-zsh" ]; then

    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/OhMyZsh.sh
    chmod +x /tmp/OhMyZsh.sh
    ZSH=$DSTPATH/oh-my-zsh /tmp/OhMyZsh.sh --unattended
    rm /tmp/OhMyZsh.sh

    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

mkdir -p $DSTPATH

curl $BASEURL/theme.omp.json -so $DSTPATH/theme.omp.json
curl $BASEURL/zshrc          -so $HOME/.zshrc
curl $BASEURL/version        -so $DSTPATH/version


chsh -s $(which zsh)


clear


echo Thank you for choosing Leon\'s ZSH Config.
echo Have an Awesome day!

