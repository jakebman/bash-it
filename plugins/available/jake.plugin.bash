# shellcheck shell=bash
about-plugin 'some functions (cdd - go to parent folder of; cddd - go to grandparent folder of)'

function cdd () {
  if [ "$#" -eq 0 ] ; then
    cd ..
  elif [ -d "$1" ] ; then
    cd "$1/.."
  else
    cd "$(dirname "$1")"
  fi
}
