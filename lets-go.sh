#!/bin/bash

######################################################################
# ThreatCode/dotfiles - Remote Runnable Dotfile Setup Script         #
######################################################################
# This script will clone + install, or update dotfiles from git      #
# Be sure to read through the repo before running anything here      #
# For more info, read docs: https://github.com/threatcode/dotfiles   #
#                                                                    #
# Config Options:                                                    #
# - DOTFILES_REPO - Optionally sets the source repo to be cloned     #
# - DOTFILES_DIR - Optionally sets the local destination directory   #
######################################################################

# If not already set, specify dotfiles destination directory and source repo
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Documents/config/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/threatcode/dotfiles.git}"

# Print starting message
echo -e "\033[1;35m""threatcode/Dotfiles Installation Script 🧰
\033[0;35mThis script will install or update specified dotfiles:
- From \033[4;35m${DOTFILES_REPO}\033[0;35m
- Into \033[4;35m${DOTFILES_DIR}\033[0;35m
Be sure you've read and understood the what will be applied.\033[0m\n"

# If dependencies not met, install them
if ! hash git 2> /dev/null; then
  bash <(curl -s  -L 'https://raw.githubusercontent.com/threatcode/dotfiles/HEAD/scripts/installs/prerequisites.sh')
fi

# If dotfiles not yet present then clone
if [[ ! -d "$DOTFILES_DIR" ]]; then
  mkdir -p "${DOTFILES_DIR}" && \
  git clone --recursive ${DOTFILES_REPO} ${DOTFILES_DIR}
fi

# Execute setup or update script
cd "${DOTFILES_DIR}" && \
chmod +x ./install.sh && \
./install.sh --no-clear

# EOF
