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

repo_loc() {
  local repo=$1
  if [ -L ~/.homesyncrc ]; then
    command file -bh ~/.homesyncrc | awk '{ print $NF }'
  else
    # this is kinda a never catch -- the only time I *should* call this function without an arg I don't need it anyway
    # but it's a weird corner case and you never know
    [ -z "$repo" ] && echo "~/.homesyncrc is missing (or not a link to the repo), but I don't have a repo to set... bailing." && exit 2
    ln -s $repo ~/.homesyncrc
    echo $repo
  fi
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

  if ( ! echo $src | grep -s nodot >/dev/null ); then
    special="${src}.nodot"
    if [ -e "$special" ]; then
      dst="${HOME}/${src}"
    fi
  fi

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
    restore)
      cmd="cp -vf"
      src="${HOME}/.${src}.orig"
      dst="${HOME}/.${src}"
      ;;
    *)
      echo "Unknown mode: $mode"
      exit 1
      ;;
  esac


  if [ -e "${dst}" ]; then
    # exists
    if [ -L "${dst}" ]; then
      # is a link
      if [ -n "$debug" ]; then
        command file -h $dst
      fi
      return
    elif [ -d "${dst}" ]; then
      # is a directory
      return
    elif [ -f "${dst}" ]; then
      # is a file
      backup $dst
    else
      echo "$dst is something I don't recognize (file, link, directory)"
      exit 1
    fi
  fi
  # doesn't exist
  echo "setup ($mode) $dst"
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
    REPO_LOC=$(repo_loc $2)
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
    ;;
  restore)
    repo_loc
    echo "Restoring originals (if present)"
    mode="restore"
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
