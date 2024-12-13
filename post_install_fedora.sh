#!/usr/bin/env bash

# ---------------------------------------------------------
# Fedora Post-Installation Script
# ---------------------------------------------------------
# This script automates:
# - System update
# - Google Chrome installation
# - RPM Fusion (free and nonfree) and NVIDIA drivers
# - VSCode and JetBrains Toolbox installation
# - GNOME Tweaks, GNOME Extensions, and Papirus Icons
# - Docker installation and user permission configuration
# - Spotify installation via Flatpak
# - Node.js installation via NVM
# - Homebrew installation, then installing Go via Homebrew
# - Zsh installation, setting as default shell, Oh My Zsh, and plugins:
#   docker, docker-compose, zsh-syntax-highlighting, zsh-autosuggestions
#
# Run this script after a fresh Fedora installation.
#
# After completion, log out and log in again to apply Docker and Zsh changes.
# ---------------------------------------------------------


# Logging functions
function msg_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

function msg_ok() {
    echo -e "\e[1;32m[OK]\e[0m $1"
}

function msg_warn() {
    echo -e "\e[1;33m[WARN]\e[0m $1"
}

function msg_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}


# ---------------------------------------------------------
# Check privileges
# ---------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
   msg_warn "You are running this script as root. It is recommended to run as a normal user with sudo when prompted."
fi


# ---------------------------------------------------------
# System Update
# ---------------------------------------------------------
msg_info "Updating the system..."
sudo dnf update -y && msg_ok "System updated."


# ---------------------------------------------------------
# Google Chrome
# ---------------------------------------------------------
msg_info "Enabling repositories and installing Google Chrome..."
sudo dnf install -y dnf-plugins-core fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo dnf install -y google-chrome-stable && msg_ok "Google Chrome installed."


# ---------------------------------------------------------
# RPM Fusion and NVIDIA Drivers
# ---------------------------------------------------------
msg_info "Enabling RPM Fusion..."
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  && msg_ok "RPM Fusion enabled."

sudo dnf update -y

msg_info "Installing NVIDIA drivers..."
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda && msg_ok "NVIDIA drivers installed."


# ---------------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------------
msg_info "Adding VSCode repository..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

msg_info "Installing VSCode..."
sudo dnf install -y code && msg_ok "VSCode installed."


# ---------------------------------------------------------
# JetBrains Toolbox
# ---------------------------------------------------------
JETBRAINS_VERSION="1.28.1.15219" # Adjust to the latest version available
JBT_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_VERSION}.tar.gz"

msg_info "Downloading and installing JetBrains Toolbox (version ${JETBRAINS_VERSION})..."
wget -q $JBT_URL -O /tmp/jetbrains-toolbox.tar.gz
sudo tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/
TOOLBOX_DIR=$(find /opt -type d -name "jetbrains-toolbox-*" | head -n 1)
if [ -d "$TOOLBOX_DIR" ]; then
    sudo mv "$TOOLBOX_DIR" /opt/jetbrains-toolbox
    sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
    msg_ok "JetBrains Toolbox installed. Run 'jetbrains-toolbox' to start."
else
    msg_error "Could not install JetBrains Toolbox."
fi


# ---------------------------------------------------------
# GNOME Tweaks and Extensions
# ---------------------------------------------------------
msg_info "Installing GNOME Tweaks and GNOME Extensions..."
sudo dnf install -y gnome-tweaks gnome-extensions-app && msg_ok "GNOME Tweaks and Extensions installed."


# ---------------------------------------------------------
# Papirus Icon Theme
# ---------------------------------------------------------
msg_info "Installing Papirus Icon Theme..."
sudo dnf install -y papirus-icon-theme && msg_ok "Papirus Icon Theme installed."

msg_info "Setting Papirus as the default icon theme..."
gsettings set org.gnome.desktop.interface icon-theme 'Papirus' && msg_ok "Papirus theme applied."


# ---------------------------------------------------------
# Docker
# ---------------------------------------------------------
msg_info "Installing Docker..."
sudo dnf remove -y docker docker-common docker-selinux docker-engine docker-ce docker-ce-cli
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && msg_ok "Docker installed."

msg_info "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

msg_info "Adding user to 'docker' group..."
sudo usermod -aG docker $USER && msg_ok "User added to docker group (effective after logout/login)."


# ---------------------------------------------------------
# Spotify via Flatpak
# ---------------------------------------------------------
msg_info "Installing Flatpak and Spotify..."
sudo dnf install -y flatpak
if ! flatpak remote-list | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    msg_ok "Flathub added."
fi
sudo flatpak install -y flathub com.spotify.Client && msg_ok "Spotify installed."


# ---------------------------------------------------------
# Node via NVM
# ---------------------------------------------------------
msg_info "Installing NVM (Node Version Manager) and Node LTS..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Load NVM in this session
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && echo "$HOME/.nvm" || echo "$XDG_CONFIG_HOME/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

nvm install --lts && msg_ok "Node.js LTS installed via NVM."


# ---------------------------------------------------------
# Homebrew and Go
# ---------------------------------------------------------
msg_info "Installing Homebrew on Linux..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Load brew in this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

msg_ok "Homebrew installed."

msg_info "Installing Go via Homebrew..."
brew install go && msg_ok "Go installed via Homebrew."


# ---------------------------------------------------------
# Zsh, Oh My Zsh, and plugins
# ---------------------------------------------------------
msg_info "Installing Zsh..."
sudo dnf install -y zsh && msg_ok "Zsh installed."

msg_info "Setting Zsh as default shell..."
chsh -s $(which zsh) $USER

msg_info "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
    msg_error "Oh My Zsh installation failed."
    exit 1
}
msg_ok "Oh My Zsh installed."

# Oh My Zsh custom directory
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

msg_info "Installing Oh My Zsh plugins (zsh-syntax-highlighting, zsh-autosuggestions)..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
msg_ok "Additional plugins installed."

msg_info "Configuring plugins in .zshrc..."
cp ~/.zshrc ~/.zshrc.backup.$(date +%F-%T)
sed -i 's/^plugins=(.*)/plugins=(git docker docker-compose zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
msg_ok "Plugins configured: git, docker, docker-compose, zsh-syntax-highlighting, zsh-autosuggestions."


# ---------------------------------------------------------
# Finishing
# ---------------------------------------------------------
msg_ok "All installations and configurations completed!"
echo "------------------------------------------------------------"
echo "Please:"
echo "- Log out and log back in to apply Docker and Zsh changes."
echo "- Open a new terminal so that Homebrew and NVM load properly."
echo "------------------------------------------------------------"
echo "Enjoy your configured system!"
