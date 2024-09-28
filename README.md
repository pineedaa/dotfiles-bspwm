# Pineedaa's dotfiles
## Screenshots
![desktop](assets/empty-desktop.png)
![desktop](assets/three-apps.png)
![desktop](assets/pseudotiled.png)
![desktop](assets/rofi.png)


# Apps

- OS: [ArchLinux](https://archlinux.org/)
- WM: [BSPWM](https://github.com/baskerville/bspwm)
- Terminal: [Alacritty](https://alacritty.org/)
- File explorer: [Thunar](https://wiki.archlinux.org/title/Thunar)
- Menu: [Rofi](https://github.com/davatorium/rofi)
- Shell: [Zsh](https://www.zsh.org/)
- Fetch: [Flowetch](https://github.com/migueravila/Flowetch)

The necessary packages for this environment can be installed with:
```
yay -S \
# Terminal
alacritty \
# Keybind for brightness
brightnessctl \
# Notifications
dunst \
# Shell
zsh \
oh-my-posh \
# Screenshoter
maim \
# Theme
orchis-theme \
# Menu
rofi \
# Set wallpaper
feh \
gtk \
gtk2 \
gtk3 \
gtk4 \
# Icons
epapirus-icon-theme \
# Cursor
xcursor-comix \
xorg-xsetroot \
# Fonts
ttf-ubuntu-mono-nerd \
ttf-jetbrains-mono-nerd \
# Adjust volume with the scripts
pactl \
pamixer \
# Bar
eww \
# Compositor
picom-arian8j2-git \
# Screenlocker
betterlockscreen
```

# Install

You can clone this dotfiles where you prefere and inside the folder you can simply execute `stow .`.
You can install the [stow](https://www.gnu.org/software/stow/manual/stow.html) package with pacman:

`$ pacman -S stow`

There is also an install script to automate the process

> [!CAUTION]
> The script is untested. Please, let me know if you encounter any errors.

> [!WARNING]  
> This script only works for Arch Linux.

The bar is made with [eww](https://github.com/elkowar/eww). It is a fork of [rxyhn](https://github.com/rxyhn/tokyo)'s dotfiles.
![bar](assets/bar.png)

# Prompt

The prompt is made with [oh-my-posh](https://ohmyposh.dev/). It displays a green heart ( <3 ) when the previous command exit code was 0 or a red broken heart like mine ( </3 ) when the exit code was not 0.

![prompt](assets/prompt.png)

# Sudo askpass

There is also an script and an environment variable that is used to ask your sudo password without having to interact with the terminal. That is really useful when you want to open an app or execute an script with sudo permissions but from a .desktop file.

To see how it works execute ´sudo -A \<command to execute\>´

![askpass](assets/sudo-ls.png)

This is useful when you want to create a cli app that requires admin privileges and you don't want it to be executed via terminal.
For example you can create a .desktop file to execute and app/script that needs sudo permissions and asks you for the password with the rofi menu.


![askpass](assets/sudo-ollama.png)

For the askpass to work you must set the SUDO_ASKPASS variable to a binary or script that returns the password in the stdout.
In my case I export the variable in the autostart script of BSPWM and it is set to `$HOME/.config/bspwm/scripts/askpass`. When you have this variable set it will use automatically this path to the script to ask the password.
