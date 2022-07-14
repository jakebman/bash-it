# shellcheck shell=bash
about-plugin 'install the tools that Jake wants with jake-install-tools'


function _jake-find-tool() {
  if ! _binary_exists "$1" ; then
    TOOLS_TO_INSTALL="${TOOLS_TO_INSTALL} ${1}"
  fi
}

function jake-install-tools() {
  about "installs the tools jake uses"
  TOOLS_TO_INSTALL=""
  _jake-find-tool python3-pygments
  _jake-find-tool dos2unix
  _jake-find-tool tree
  _jake-find-tool jq

  echo sudo apt install $TOOLS_TO_INSTALL
       sudo apt install $TOOLS_TO_INSTALL
}
