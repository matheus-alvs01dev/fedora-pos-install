# Fedora Post-Installation Script
This script automates the initial setup of a fresh Fedora installation, installing and configuring a range of tools commonly used in development and daily workflows.

Features
System Update: Updates all packages to the latest versions.
Browsers & Tools: Installs Google Chrome and Visual Studio Code.
Repositories & Drivers: Enables RPM Fusion (free and nonfree) and installs NVIDIA proprietary drivers.
Development Tools:
JetBrains Toolbox for easy management of JetBrains IDEs.
NVM (Node Version Manager) and Node.js (LTS version).
Homebrew (Linux) and Go via Homebrew.
GNOME Customization:
GNOME Tweaks and GNOME Extensions.
Papirus Icon Theme (applied as default).
Containers: Installs Docker, enables the service, and adds the current user to the docker group.
Music: Installs Spotify via Flatpak.
Shell & Productivity:
Installs Zsh, sets it as the default shell.
Installs Oh My Zsh.
Configures Oh My Zsh plugins: git, docker, docker-compose, zsh-syntax-highlighting, and zsh-autosuggestions.
Requirements
A fresh Fedora installation (or an updated Fedora system).
Internet access.
Ability to run sudo commands.
Installation
Download the Script:

bash
Copiar código
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
Make the Script Executable:

bash
Copiar código
chmod +x post_install_fedora.sh
Run the Script:

bash
Copiar código
./post_install_fedora.sh
If prompted, enter your administrator password. The script will run through all steps automatically.

Post-Installation Steps
Logout/Login: After the script finishes, log out and log back in. This ensures that:
The docker group permissions apply to your user.
Zsh is set as your default shell.
Open a New Terminal: NVM and Homebrew environment variables will be properly loaded in a new terminal session.
Customization
Versions & Packages:
Feel free to edit the script to adjust versions (e.g., JetBrains Toolbox) or add/remove packages.

Oh My Zsh Configuration:
The script modifies .zshrc to include specific plugins. You can change or add more plugins as needed.

Troubleshooting
Shell not changed: If Zsh didn't become your default shell, manually run:

bash
Copiar código
chsh -s $(which zsh)
and then log out and back in again.

NVM/Homebrew not found: Ensure you've opened a new terminal session. Add the recommended lines from the Homebrew installer to your shell initialization file (~/.bashrc, ~/.zshrc, etc.).

Contributing
If you have suggestions or improvements, feel free to submit a pull request or open an issue on the repository.