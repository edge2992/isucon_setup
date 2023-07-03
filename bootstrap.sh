#!/bin/bash -eu
# shellcheck disable=SC2317


# tool_download_path
ALP_SOURCE_URL="https://github.com/tkuchiki/alp/releases/download/v1.0.12/alp_linux_arm64.zip"

# tool install path

if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# funciton

has() {
  type "$1" > /dev/null 2>&1
}

dotfiles() {
  echo $BLUE
  cat <<\EOF
 _                                        _
(_)___ _   _  ___ ___  _ __      ___  ___| |_ _   _ _ __
| / __| | | |/ __/ _ \| '_ \    / __|/ _ \ __| | | | '_ \
| \__ \ |_| | (_| (_) | | | |   \__ \  __/ |_| |_| | |_) |
|_|___/\__,_|\___\___/|_| |_|___|___/\___|\__|\__,_| .__/
                           |_____|                 |_|
EOF
  echo $NORMAL
}

usage() {
  echo $YELLOW
  cat <<\EOF
Commands:
  download (download tools by shellscript. alp and ab would be installed.)
  quit
EOF
  echo $NORMAL
}

check_arch() {
  if [ "$(uname -m)" = "arm64" ]; then
    echo "${GREEN}arm64 detected.$NORMAL"
  else
    echo "${RED}arm64 not detected. This script is only runnable in arm64.$NORMAL"
    exit 1
  fi
}

alp_download() {
  pushd tmp
  wget -nv "$ALP_SOURCE_URL"
  unzip "$(basename "$ALP_SOURCE_URL")"
  sudo install ./alp /usr/local/bin/alp
  rm "$(basename "$ALP_SOURCE_URL")"
  rm alp
  popd

  if [ $? = 0 ]; then
    echo "${GREEN}Successfully installed alp. ✔︎ $NORMAL"
  else
    echo "${RED}An unexpected error occurred when trying to install alp.$NORMAL"
  fi
}

apt_install() {
  if [ "$(uname -s)" == "Linux" ]; then
    if [ -n "$(command -v apt)" ]; then

      echo "${BOLD}Updating apt...$NORMAL"
      sudo apt update
      echo "${BOLD}Installing necessary packages for nvim plugins...$NORMAL"
      sudo apt install -y apache2-utils

      if [ $? = 0 ]; then
        echo "${GREEN}Successfully installed necessary packages. ✔︎$NORMAL"
      else
        echo "${RED}An unexpected error occurred when trying to install packages.$NORMAL"
      fi
    else
      echo "${RED}This command requires apt package manager, which is not available on this system.$NORMAL"
    fi
  else
    echo "${RED}This command is intended to be executed only on Linux.$NORMAL"
  fi
}

download() {
  # check if arch is arm64
  check_arch
  
  cd "$HOME"
  mkdir -p tmp

  # alp
  if ! has "alp"; then
    alp_download
  else
    echo "${BOLD}alp already exists.$NORMAL"
  fi

  # apt install (ab)
  apt_install
}


# main
main() {
  usage
  echo -n "${BOLD}command: $NORMAL"
  read command
  case $command in
    quit)
      echo "bye!"
      exit 0
      ;;
    download)
      download
      ;;
    *)
      echo "${RED}bootstrap: command not found.$NORMAL"
      main
      ;;
  esac
}
dotfiles
main
exit 0
