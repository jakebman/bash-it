
export EDITOR=vim
export VISUAL=vim

# Allow less to simply dump the output to STDOUT when it would all fit on a single page
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW... enables color interpretation
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
export LESS="--quit-if-one-screen --quit-at-eof --no-init --RAW-CONTROL-CHARS"

if _command_exists pygmentize ; then
  # see `man less`, section "INPUT PREPROCESSOR"
  export  LESSOPEN='|- pygmentize -f 256 -O style="${BASH_IT_CLESS_STYLE:-default}" -g %s'
fi

function vars {
  if [ "$#" -eq 0 ] ; then
    # magic incantation from the internet
    # Basically, prints the variables and functions of
    # the current bash session, but doesn't print the functions
    (set -o posix; set)
  else
     (set -o posix; set) | grep "$@"
  fi
}

function jake_debug {
	echo `date +"%r"` "$@" >>~/jake-bashit-debug
}
