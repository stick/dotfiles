#!/bin/bash
#
# $Id$

usage() {
    echo "Usage:"
    echo "$0 [ACTION] [option]"
    echo "Set up homedir config files to point to a RCS repo of some type"
    echo
    echo "  Actions:"
    echo "    setup: sets up link between repository of configs and your homedir"
    echo "      $0 setup path_to_repo [mode]"
    echo "       mode: link - create symlinks between repo and configs - the default when unspecified"
    echo "         $0 setup path_to_repo link"
    echo "       mode: copy - copy configs from repo (ie don't use symlinks)"
    echo "         $0 setup path_to_repo copy"
    echo "    sync: when using copy mode this refreshes the copies in your homedir"
    echo "    whatever file has the newer mtime will be the source"
    echo "    ie if ~/.bashrc is newer than ~/dotfiles/bashrc: ~/.bashrc -> ~/dotfiles/bashrc"
    echo "    ie if ~/dotfiles/bashrc is newer than ~/.bashrc: ~/dotfiles/bashrc -> ~/.bashrc"
    echo "      $0 sync"
    echo "    debug"
    echo "       debug mode, don't actually do any copies or links but show what would be done"
    echo "       put debug as first action then rest of command as normal"
    echo
    echo "Example:"
    echo "  $0 setup ~/dotfiles.git"
    echo "  $0 sync"
    exit $1
}

backup() {
  local dst=$1
  echo "${dst} exists... copying to ${dst}.orig"
  ${debug} cp -rf $dst ${dst}.orig
}

object() {
  local src=$1
  local mode=$2
  local dst="${HOME}/.${src}"

  case $mode in
    link)
      cmd="ln -sf"
      ;;
    copy)
      cmd="cp -f"
      ;;
    sync)
      cmd=""
      ;;
    *)
      echo "Unknown mode: $mode"
      exit 1
      ;;
  esac


  if [ -e "${dst}" ]; then
    # exists
    if [ -f "${dst}" ]; then
      # is a file
      backup $dst
    elif [ -d "${dst}" ]; then
      # is a directory
        for o in $src/*; do
          object $o $mode
        done
    elif [ -L "${dst}" ]; then
      # is a link
      return
    else
      echo "$dst is something I don't recognize (file, link, directory)"
      exit 1
    fi
  fi
  # doesn't exist
  ${debug} $cmd $REPO_LOC/$src $dst
}

if [ "$#" -gt 2 ]; then
  # likely debug mode
  is_debug=$1
  shift
  if [ "$is_debug" == "debug" ]; then
    debug="echo"
  else
    echo "Unknown action: $is_debug"
    usage
  fi
fi

case $1 in
  setup)
    if [ -z "$2" ]; then
      usage
    else
      REPO_LOC=$2
      if [ -d "$REPO_LOC" ]; then
        echo "Setting up initial homedir links to $REPO_LOC"
        if [ -z "$3" ]; then
          mode="link"
        else
          mode=$3
        fi
      else
        echo "$REPO_LOC is not a directory"
        exit 1
      fi
    fi
    ;;
  *)
    usage
    ;;
esac

# loop through repo contents
cd $REPO_LOC
for ob in *; do
  object $ob $mode
done
