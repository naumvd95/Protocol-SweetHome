#!/bin/bash
set -ex
set -o pipefail


# TODO rewrite workaround 
exesudo() {
  local _funcname_="$1"
  local params=( "$@" )                       ## array containing all params passed here
  local tmpfile="/private/dev/shm/$RANDOM"    ## temporary file
  local regex                                 ## regular expression

  unset params[0]              ## remove first element
  # params=( "${params[@]}" )     ## repack array

  content="#!/bin/bash\n\n"
  content="${content}source "$DIRNAME/utils/logging.sh"\n\n"
  content="${content}params=(\n"

  regex="\s+"
  for param in "${params[@]}"; do
    if [[ "$param" =~ $regex ]]; then
      content="${content}\t\"${param}\"\n"
    else
      content="${content}\t${param}\n"
    fi
  done

  content="$content)\n"
  echo -e "$content" > "$tmpfile"
  echo "#$( type "$_funcname_" )" >> "$tmpfile"
  echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"
  sudo bash "$tmpfile"
  rm "$tmpfile"
}

backup_dotfiles() {
  e_header "Stage: backup dotfiles"
  mkdir -p $DIRNAME/backup/dotfiles

  dotfiles_dir=$DIRNAME/backup/dotfiles
  dirname=$(echo "$dotfiles_dir" | awk -F'/' '{ print $NF }')
  file_list=$(find "$dotfiles_dir" -type f)
  FL=()

  for file in $file_list; do
    fn=$(echo "$file" | awk -F'/' '{print $NF}')
    homedir_file=$HOME${file#$DIRNAME/$dirname}
    mkdir -p "${homedir_file%$fn}"
    if [[ -f $homedir_file  ]]; then
      rm -f "$homedir_file"
    fi
    e_arrow "Linking $fn to ${homedir_file%$fn}..."
    ln -s "$file" "$homedir_file"
    if [[ $? -ne 0 ]]; then
      FL+=($file)
    fi
  done

  if [[ ${#FL[@]} -eq 0 ]]; then
    e_success "All files successfully linked!"
  else
    e_error "Failed to link $(IFS=" "; echo ${FL[*]})"
  fi
}



setup_env() {
  DIRNAME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  USERNAME=$(whoami)
  export DIRNAME
  export USERNAME
  source "$DIRNAME/utils/logging.sh"
}


print_help() {
  echo '-h - print this help'
  echo '-v - backup vimrc'
  echo '-z - backup zshrc'
  echo '-b - backup bashrc'
  echo '-g - backup gitconfig'
  echo '-A - backup all dotfiles'
}

setup_env
while getopts "adgcAPGSNBDho" opt; do
  case $opt in
    a)
      setup_dotfiles "$DIRNAME"/dotfiles
      exesudo setup_repos "$DIRNAME"/pkgs/repos_list
      exesudo install_apt_packages "$DIRNAME"/pkgs/apt
      exesudo install_snap_packages "$DIRNAME"/pkgs/snap
      exesudo install_pip_packages "$DIRNAME"/pkgs/pip
      exesudo install_gem_packages "$DIRNAME"/pkgs/gem
      exesudo install_npm_packages "$DIRNAME"/pkgs/npm
      configure_git_repos "$DIRNAME"/pkgs/git
      setup_brew "$DIRNAME"/pkgs/brew
      setup_ngrok
      clone_bin_from_url cerebro https://github.com/KELiON/cerebro/releases/download/v0.3.1/cerebro-0.3.1-x86_64.AppImage
      clone_bin_from_url dockstation https://github.com/DockStation/dockstation/releases/download/v1.4.1/dockstation-1.4.1-x86_64.AppImage
      clone_bin_from_url tmuxinator.bash https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash
      exesudo setup_docker_service
      configure_vim
    ;;
    d)
      exesudo setup_docker_service
    ;;
    A)
      exesudo setup_repos "$DIRNAME/pkgs/repos_list"
      exesudo install_apt_packages "$DIRNAME/pkgs/apt"
    ;;
    P)
      exesudo install_pip_packages "$DIRNAME"/pkgs/pip
    ;;
    G)
      exesudo install_gem_packages "$DIRNAME"/pkgs/gem
    ;;
    S)
      exesudo install_snap_packages "$DIRNAME"/pkgs/snap
    ;;
    N)
      exesudo install_npm_packages "$DIRNAME"/pkgs/npm
    ;;
    B)
      setup_brew "$DIRNAME"/pkgs/brew
    ;;
    D)
      clone_bin_from_url tmuxinator.bash https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash
      setup_dotfiles "$DIRNAME"/dotfiles
    ;;
    g)
      configure_git_repos "$DIRNAME"/pkgs/git
    ;;
    c)
      configure_vim
    ;;
    h)
      print_help
    ;;
    o)
      setup_go
    ;;
  esac
done

