#!/usr/bin/env bash

######################################################################
# 🧰 ThreatCode/Dotfiles - All-in-One Install  Script for Unix       #
######################################################################
# Fetches latest changes, symlinks files, and installs dependencies  #
# Then sets up ZSH, TMUX, Vim as well as OS-specific tools and apps  #
# Checks all dependencies are met, and prompts to install if missing #
#                                                                    #
# OPTIONS:                                                           #
#   --auto-yes: Skip all prompts, and auto-accept all changes        #
#   --no-clear: Don't clear the screen before running                #
#                                                                    #
# ENVIRONMENTAL VARIABLES:                                           #
#   DOTFILES_DIR: Where to save dotfiles to (default: ~/.dotfiles)   #
#   DOTFILES_REPO: Git repo to USE (default: threatcode/Dotfiles)    #
#                                                                    #
# IMPORTANT: Before running, read through everything very carefully! #
######################################################################

# Set variables for reference
PARAMS=$* # User-specified parameters
CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
SYSTEM_TYPE=$(uname -s) # Get system type - Linux / MacOS (Darwin)
PROMPT_TIMEOUT=15 # When user is prompted for input, skip after x seconds
START_TIME=`date +%s` # Start timer
SRC_DIR=$(dirname ${0})

# Dotfiles Source Repo and Destination Directory
REPO_NAME="${REPO_NAME:-threatcode/Dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-${SRC_DIR:-$HOME/.dotfiles}}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${REPO_NAME}.git}"

# Config Names and Locations
TITLE="🧰 ${REPO_NAME} Setup"
SYMLINK_FILE="${SYMLINK_FILE:-symlinks.yaml}"
DOTBOT_DIR="lib/dotbot"
DOTBOT_BIN="bin/dotbot"

# Color Variables
CYAN_B='\033[1;96m'
YELLOW_B='\033[1;93m'
RED_B='\033[1;31m'
GREEN_B='\033[1;32m'
PLAIN_B='\033[1;37m'
RESET='\033[0m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'

# Clear the screen
if [[ ! $PARAMS == *"--no-clear"* ]] && [[ ! $PARAMS == *"--help"* ]] ; then
  clear
fi

# If set to auto-yes - then don't wait for user reply
if [[ $PARAMS == *"--auto-yes"* ]]; then
  PROMPT_TIMEOUT=1
  AUTO_YES=true
fi

# Function that prints important text in a banner with colored border
# First param is the text to output, then optional color and padding
make_banner () {
  bannerText=$1
  lineColor="${2:-$CYAN_B}"
  padding="${3:-0}"
  titleLen=$(expr ${#bannerText} + 2 + $padding);
  lineChar="─"; line=""
  for (( i = 0; i < "$titleLen"; ++i )); do line="${line}${lineChar}"; done
  banner="${lineColor}╭${line}╮\n│ ${PLAIN_B}${bannerText}${lineColor} │\n╰${line}╯"
  echo -e "\n${banner}\n${RESET}"
}

# Explain to the user what changes will be made
make_intro () {
  C2="\033[0;35m"
  C3="\x1b[2m"
  echo -e "${CYAN_B}The seup script will do the following:${RESET}\n"\
  "${C2}(1) Pre-Setup Tasls\n"\
  "  ${C3}- Check that all requirements are met, and system is compatible\n"\
  "  ${C3}- Sets environmental variables from params, or uses sensible defaults\n"\
  "  ${C3}- Output welcome message and summary of changes\n"\
  "${C2}(2) Setup Dotfiles\n"\
  "  ${C3}- Clone or update dotfiles from git\n"\
  "  ${C3}- Symlinks dotfiles to correct locations\n"\
  "${C2}(3) Install packages\n"\
  "  ${C3}- On MacOS, prompt to install Homebrew if not present\n"\
  "  ${C3}- On MacOS, updates and installs apps liseted in Brewfile\n"\
  "  ${C3}- On Arch Linux, updates and installs packages via Pacman\n"\
  "  ${C3}- On Debian Linux, updates and installs packages via apt get\n"\
  "  ${C3}- On Linux desktop systems, prompt to install desktop apps via Flatpak\n"\
  "  ${C3}- Checks that OS is up-to-date and critical patches are installed\n"\
  "${C2}(4) Configure system\n"\
  "  ${C3}- Setup Vim, and install / update Vim plugins via Plug\n"\
  "  ${C3}- Setup Tmux, and install / update Tmux plugins via TPM\n"\
  "  ${C3}- Setup ZSH, and install / update ZSH plugins via Antigen\n"\
  "  ${C3}- Apply system settings (via NSDefaults on Mac, dconf on 
Linux)\n"\
  "  ${C3}- Apply assets, wallpaper, fonts, screensaver, etc\n"\
  "${C2}(5) Finishing Up\n"\
  "  ${C3}- Refresh current terminal session\n"\
  "  ${C3}- Print summary of applied changes and time taken\n"\
  "  ${C3}- Exit with appropriate status code\n\n"\
  "${PURPLE}You will be prompted at each stage, before any changes are made.${RESET}\n"\
  "${PURPLE}For more info, see GitHub: \033[4;35mhttps://github.com/${REPO_NAME}${RESET}"
}

# Cleanup tasks, run when the script exits
cleanup () {
  # Reset tab color and title (iTerm2 only)
  echo -e "\033];\007\033]6;1;bg;*;default\a"

  # Unset re-used variables
  unset PROMPT_TIMEOUT
  unset AUTO_YES

  # dinosaurs are awesome
  echo "🦖"
}

# Checks if a given package is installed
command_exists () {
  hash "$1" 2> /dev/null
}
