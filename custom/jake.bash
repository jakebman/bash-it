
export EDITOR=vim
export VISUAL=vim

# Allow less to simply dump the output to STDOUT when it would all fit on a single page
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW... enables color interpretation
export LESS="--quit-if-one-screen --no-init --RAW-CONTROL-CHARS"

function vars {
	# magic incantation from the internet
	# Basically, prints the variables and functions of 
	# the current bash session, but doesn't print the functions
	(set -o posix; set)
}

function jake_debug {
	echo `date +"%r"` "$@" >>~/jake-bashit-debug
}
