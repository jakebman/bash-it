
# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Gonna try this out for a bit
alias cat='bat --plain'

# Allow j!! to work for a previous ack query
alias jack=j

# I want jq to work like the jqless I created for the jq.plugin.bash
alias jq=jqless

# Because... tree should basically always be paged
alias tree=ltree

export CLICOLOR_FORCE="setting this value to ANYTHING forces 'tree' to use colors so we don't need to alias tree='tree -C'. See man(1) tree"

# Allow less to simply dump the output to STDOUT when it would all fit on a single page
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW... enables color interpretation
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
export LESS="--quit-if-one-screen --quit-at-eof --no-init --RAW-CONTROL-CHARS"
export LESSHISTFILE="${HOME}/.config/lesshst" # I like editing ~/.lessfilter, and this keeps getting in the way
export LESSSTYLE=sas

if [ -f "$HOME/.cargo/env" ] ; then
	source "$HOME/.cargo/env"
fi

# TODO: I'd like to be able to apply these to stdin as well (the "||- your-command %s" variation).
# That'll take more infrastructure.
# Read more in $HOME/.lessfilter
if _command_exists lesspipe ; then # most likely; gets zip files too
  eval `lesspipe`
elif _command_exists "$HOME/.lessfilter" ; then # my custom shim for coloring lesspipe. lesspipe calls it
  _log_warn "lesspipe is not available, but ~/.lessfilter is present. Using that"
  export LESSOPEN="|| $HOME/.lessfilter %s"
elif _command_exists pygmentize ; then # fallback if somehow we don't have anything else useful
  # see `man less`, section "INPUT PREPROCESSOR"
  # We only use pygmentize on named files (not '||-') because
  # I don't really like the default colors that are guessed
  _log_warn "lesspipe and ~/.lessfilter are missing. Using pygmentize bare"
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
    # $@ is unecessary, as it's empty. Keeps parallel structure, though.
    # implicitdiff is my own tool, which does diff, but also falls back to git status
    git implicitdiff "$@"
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    git diff "$@"
  else
    command diff "$@"
  fi
}

function delta {
  about "allow you to type the bare word 'delta' and get an automatic git delta, while still not harming the delta command"
  if [[ "$#" -eq 0 ]] ; then
    # $@ is unecessary, as it's empty. Keeps parallel structure, though.
    # we choose implicitdiff here, because it serves diff well too
    git -c core.pager=delta implicitdiff "$@"
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    # git-delta is aliased in git to to a git diff with delta as the pager
    git delta "$@"
  else
    command diff "$@"
  fi
}

# TODO: implicit arguments for vim - allow a bare vim invocation to invoke
# either '0 or :browse oldfiles
# https://stackoverflow.com/a/3171327/285944
# (This might need to be in .vimrc instead, but it can live here next to the other 'no-arg becomes meaningful' commands)

function realpath {
  about "allow you to type the bare word 'realpath' and automatically be cd'd there"
  if [[ "$#" -eq 0 ]] ; then
		cd "$(command realpath .)"
  else
    command realpath "$@"
  fi
}

function doctor {
	about "just run bash-it doctor"
	time bash-it doctor
}
