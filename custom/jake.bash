
# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less

export CLICOLOR_FORCE= # force tree to use colors so we don't need to alias tree='tree -C'. See man(1) tree

# Allow less to simply dump the output to STDOUT when it would all fit on a single page
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW... enables color interpretation
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
export LESS="--quit-if-one-screen --quit-at-eof --no-init --RAW-CONTROL-CHARS"
export LESSHISTFILE="${HOME}/.config/lesshst" # I like editing ~/.lessfilter, and this keeps getting in the way
export LESSSTYLE=sas

if _command_exists lesspipe ; then # most likely; gets zip files too
  eval `lesspipe`
elif _command_exists "$HOME/.lessfilter" ; then # my custom shim for coloring lesspipe. lesspipe calls it
  export LESSOPEN="|| $HOME/.lessfilter %s"
elif _command_exists pygmentize ; then # fallback if somehow we don't have anything else useful
  # see `man less`, section "INPUT PREPROCESSOR"
  # We only use pygmentize on named files (not '||-') because
  # I don't really like the default colors that are guessed
  export LESSOPEN='|| pygmentize -f 256 -O style="${LESSSTYLE:-default}" -g %s 2>/tmp/pygmentize-errors'
else
  _log_error "pygmentize is available via sudo apt install python-pygments"
fi

function vars {
  if [ "$#" -eq 0 ] ; then
    # magic incantation from the internet
    # Basically, prints the variables and functions of
    # the current bash session, but doesn't print the functions
    (set -o posix; set) | less
  else
     (set -o posix; set) | grep "$@" | less
  fi
}
alias var=vars # because I'm lazy

function _jake-special-single-args-for-diff {
  case $1 in
    --help) return ;;
    --version) return ;;
    -h) return ;;
    -v) return ;;
  esac
  return 1;
}

function hgrep {
  about "grep your history"
  history | grep "$@"
}

function diff {
  about "allow you to type the bare word 'diff' and get an automatic git diff, while still not harming the diff command"
  if [[ "$#" -eq 0 ]] ; then
    git diff
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    git diff
  else
    /usr/bin/env diff "$@"
  fi
}

function doctor {
	about "just run bash-it doctor"
	time bash-it doctor
}
