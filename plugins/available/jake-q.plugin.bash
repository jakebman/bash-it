# shellcheck shell=bash
about-plugin "q - an exit that doesn't exit your login shell (this overrides the general q alias)"
#NB: this is almost exactly the opposite behavior of bash's `logout` builtin

unalias q
function q {
	if grep ^- /proc/$$/cmdline -q; then
		# NB: this can be faked by running bash --login, for instance
		echo "You're at a top-level (--login) shell. Exiting here will end the terminal session"
	else
		echo "You're not at the top-level login. Exiting to your parent"
		exit
	fi
}
