#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

set -e

AUR_PACKAGES=("orchis-theme" "picom-arian8j2-git")
PACKAGES=(
  "alacritty"
  "unzip"
  "xorg-xrandr"
  "xorg-xdpyinfo"
  "brightnessctl"
  "dunst"
  "cargo"
  "zsh"
  "maim"
  "thunar"
  "rofi"
  "feh"
  "gtk2"
  "gtk3"
  "gtk4"
  "epapirus-icon-theme"
  "xcursor-comix"
  "xorg-xsetroot"
  "ttf-ubuntu-mono-nerd"
  "ttf-jetbrains-mono-nerd"
  "pamixer"
  "stow"
  "less"
  "jq"
  "bc"
)
DOTFILES_REPO="https://github.com/pineedaa/dotfiles-bspwm"
DOTFILES_INSTALL_DIR="$HOME/.dotfiles"
EWW_INSTALL_DIR="$HOME/.bin"
OH_MY_POSH_INSTALL_DIR="$HOME/.bin"


# Prompt for the sudo password at the start and update the sudo timer every 5 minutes
sudo -v
while true; do
    sudo -n true
    sleep 300
    kill -0 "$$" || exit
done 2>/dev/null &

# Function to check if the user has an AUR helper installed
get_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "yay"
    elif command -v paru &> /dev/null; then
        echo "paru"
    elif command -v pikaur &> /dev/null; then
        echo "pikaur"
    else
        echo ""
    fi
}

# Function to install packages with an AUR helper
install_with_helper() {
    local helper="$1"
    shift  # Remove the first argument (the name of the helper)

    # Install all packages with the AUR helper
    echo "Installing packages with $helper..."
    "$helper" -S --noconfirm "$@"
}

install_pkgs() {
  echo "Installing packages..."
  sudo pacman -Sy --noconfirm "$@"
}

download_aur_pkgs() {
    local dir="$1"
    mkdir -p "$dir"
    shift

    local packages=("$@") 

    # Iterate over each package in the package list
    for pkg in "${packages[@]}"; do
        # Clone the AUR repository
        echo "Cloning the repository of $pkg from AUR..."
        if git clone "https://aur.archlinux.org/${pkg}.git" "$dir/$pkg"; then
            echo "Successfully cloned $pkg."
        else
            echo "\e[31mFailed to clone $pkg.\e[0m" >&2
            continue
        fi
    done
}

install_aur_pkgs() {
    local pkgs_dir="$1"
    if [ ! -d "$pkgs_dir" ]; then
        echo "\e[31mThe specified path does not exist!\e[0m" >&2
        exit 1
    fi

    if [ -z "$(ls -A "$pkgs_dir")" ]; then
        echo "\e[31mNo packages found in $pkgs_dir!\e[0m" >&2
        exit 1
    fi

    # Iterate over each subdirectory in the repository path
    for pkg in "$pkgs_dir"/*; do
        if [ -d "$pkg" ]; then
            echo "Entering $pkg"
            cd "$pkg" || exit

            # Check that the PKGBUILD exists before running makepkg
            if [ -f "PKGBUILD" ]; then
                echo "Building and installing $pkg"
                makepkg -si --noconfirm
            else
                echo "PKGBUILD not found in $pkg, skipping..."
            fi

            cd ..
        fi
    done
}

install_eww() {
    local install_dir=$( [ -n "$1" ] && echo "$1" || echo "/usr/local/bin" )
    mkdir -p "$install_dir" # Create the binary installation directory


    local eww_dir="$(xdg-user-dir DOWNLOAD)/eww"
    if [ -e "$eww_dir" ]; then
        rm -rf "$eww_dir"
    fi

    git clone https://github.com/elkowar/eww "$eww_dir"
    cd $eww_dir && \
    cargo build --release --no-default-features --features x11 && \
    cd target/release && \
    chmod +x ./eww && \
    cp eww "$install_dir"
}

install_oh_my_posh() {
    if [ -n "$1" ]; then
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$1"
    else
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi

    if [ -e "/usr/bin/zsh" ]; then
        sudo chsh -s /usr/bin/zsh "$USER"
    fi
}

install_dotfiles() {
    git clone "$1" "$2"
    cd "$(realpath $2)" && stow .
}

# Check if there is an AUR helper installed
AUR_HELPER=$(get_aur_helper)

if [ -n "$AUR_HELPER" ]; then
    install_with_helper "$AUR_HELPER" "${PACKAGES[@]}"
else
    install_pkgs "${PACKAGES[@]}"
fi

if [ -n "$AUR_HELPER" ]; then
    # If there is an AUR helper, install the packages with it
    install_with_helper "$AUR_HELPER" "${AUR_PACKAGES[@]}"
else
    # If no AUR helper is found, proceed with manual cloning and building
    echo "No AUR helper found, proceeding with manual cloning and building..."

    REPOS_DIR="$(xdg-user-dir DOWNLOAD)/pkgs"
    if [ -d "$REPOS_DIR"]; then
        rm -rf "$REPOS_DIR"
    fi

    download_aur_pkgs "$REPOS_DIR" "${AUR_PACKAGES[@]}"
    install_aur_pkgs "$REPOS_DIR"
fi

install_eww "$EWW_INSTALL_DIR"
install_oh_my_posh "$OH_MY_POSH_INSTALL_DIR"
install_dotfiles "$DOTFILES_REPO" "$DOTFILES_INSTALL_DIR"
