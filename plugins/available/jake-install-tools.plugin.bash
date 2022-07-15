# shellcheck shell=bash
about-plugin 'install the tools that Jake wants with jake-install-tools'


function _jake-find-tool() {
  if ! _binary_exists "$1" ; then
    local to_install="${2:-${1}}"
    echo "did not find binary for $1. Adding $to_install to apt list"
    TOOLS_TO_INSTALL="${TOOLS_TO_INSTALL} ${to_install}"
  fi
}

function jake-install-tools() {
  about "installs the tools jake uses"
  # tools that we can silently installl
  _binary_exists ack || (echo "installing the single-file version of ack!" && _jake-update-ack-and-its-manpages)

  # tools that can use apt
  TOOLS_TO_INSTALL=""
  _jake-find-tool pygmentize python3-pygments
  _jake-find-tool make build-essential
  _jake-find-tool http httpie
  _jake-find-tool mr myrepos
  _jake-find-tool dos2unix
  _jake-find-tool thefuck
  _jake-find-tool unzip
  _jake-find-tool clang
  _jake-find-tool tree
  _jake-find-tool zip
  _jake-find-tool jq

  if [ -n "$TOOLS_TO_INSTALL" ] ; then
    echo sudo apt install $TOOLS_TO_INSTALL
         sudo apt install $TOOLS_TO_INSTALL
  fi

  echo # spacing

  # tools that require a manual intervention
  if ! _command_exists sdk ; then
    echo "sdkman not found! Install via instructions at https://sdkman.io/install."
    echo -e "\t" "BE CAREFUL WHEN YOU PIPE TO BASH!!! THAT IS A BAD IDEA!!!"
    echo -e "\t" "curl --silent --show-error 'https://get.sdkman.io' --output ~/install-sdkman.sh"
    echo -e "\t" "vim ~/install-sdkman.sh"
    echo -e "\t" "~/install-sdkman.sh"
    echo -e "\t" "bash-it enable plugin sdkman"
    echo # spacing
  fi


  # don't need these, but should report them anyway
  _jake-check-optional-tools

  echo "btw, check out https://devblogs.microsoft.com/commandline/updating-the-windows-console-colors/"
}

function _jake-check-optional-tools() {
  about "install tools that aren't necesarily required"

  if ! _command_exists gitstatus_check ; then
    echo "gitstatus not found! Install it via git-clone from git@github.com:romkatv/gitstatus.git into ~/bin:"
    echo -e "\t" "git clone git@github.com:romkatv/gitstatus.git ~/bin/gitstatus"
    echo -e "\t" '# then, enable the gitstatus bash-it plugin and export SCM_GIT_GITSTATUS_DIR="${HOME}/bin/gitstatus"' # single-quote saves escaping
    echo -e "\t" "# Or do both of these with:"
    echo -e "\t" "cp ~/.bashrc ~/.bashrc-backup-$$-$(date +%Y%m%d-%T) # optional if you don't care"
    echo -e "\t" 'cp "${BASH_IT}/themes/jake-bashrc" ~/.bashrc' # single-quote saves escaping
    echo -e "\t" "bash-it profile load jake-home # or similar - use the one that is most appropriate"
  fi

  _command_exists httpx ||  echo "httpx not found! Install it from https://github.com/httpx-sh/httpx/releases"

  _command_exists mvn || echo "maven is available via sdkman: sdk install maven <latest version>"
}


function _jake-update-ack-and-its-manpages {
  local bin_dir="${HOME}/bin"
  local man_dir="${bin_dir}/man"
  local ack_url="${1:-https://beyondgrep.com/ack-v3.5.0}"

  # I'm learning about manpages, so this first implementation is likely bad
  mkdir -p "${man_dir}/man1" # ack's manpage goes in man1. Add others here as needed

  local previous_ack_version
  if _command_exists ack ; then
    previous_ack_version="$(ack --version)"
  fi

  # instructions from https://beyondgrep.com/install/
  # I wish they had a -latest option.
  if curl "$ack_url" > "${bin_dir}/ack" && chmod 0755 "${bin_dir}/ack" ; then
    echo "created ack at ${bin_dir}/ack"
    # We disable color on ls because I don't want to have this one weird colored line
    ls -l --human-readable --color=never "${bin_dir}/ack"
  else
    echo "failed"
    return 1
  fi

  echo # spacing

  # set up the manpath within ~/bin; I don't want to have to maintain ~/man
  if grep "$man_dir" "${HOME}/.manpath" &>/dev/null ; then
    echo "your user-specific manpath config already knows about ${man_dir}. Woohoo!"
  else
    echo "adding a section to your ~/.manpath file that looks like this:"
    cat <<END | tee --append "${HOME}/.manpath"
# this section was added automatically by my ackrc-creation script. I really hope it didn't break anything
# -Jake Boeckerman
MANDATORY_MANPATH		${man_dir}
MANPATH_MAP		${bin_dir}		${man_dir}
# END section
END
  fi

  echo # spacing

  if _command_exists pod2man ; then
    local manfile="${man_dir}/man1/ack.1p"
    pod2man ~/bin/ack >$manfile
    echo "manfile created at ${manfile}. It looks like:"
    ls -l --human-readable "$manfile"
  else
    echo "please install pod2man. Probably via apt install perl"
    return 1
  fi

  echo # spacing

  if _command_exists mandb ; then
    mandb --user-db || return 1
    echo # spacing
    echo mandb user db updated
  else
    echo "please install mandb. Otherwise, this won't work"
    return 1
  fi

  echo # spacing

  if [ -n "$previous_ack_version" ] ; then
    echo "Checking against previous ack version..."
    echo "$previous_ack_version" | grep ack
    echo # spacing
    if ack --version | grep "$previous_ack_version" &>/dev/null ; then
      echo "This was the previous ack version. No update actually occurred. Check https://beyondgrep.com/install/ for a newer version"
      echo "You can modify this script, or simply pass the new url to this script"
    else
      echo "This ack version differs from the previous one. Yay!"
    fi
  else
    echo "This appears to be your first ack version - welcome to ack!"
  fi
}
