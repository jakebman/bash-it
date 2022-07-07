
export EDITOR=vim
export VISUAL=vim

function vars {
	# magic incantation from the internet
	# Basically, prints the variables and functions of 
	# the current bash session, but doesn't print the functions
	(set -o posix; set)
}

function jake_debug {
	echo `date +"%r"` "$@" >>~/jake-bashit-debug
}
