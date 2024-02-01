# shellcheck shell=bash
about-plugin "q - an exit that doesn't exit your login shell (this overrides the general q alias)"
#NB: this is almost exactly the opposite behavior of bash's `logout` builtin

unalias q
function q {
	if shopt -q login_shell; then
		# NB: this isn't *necessarily* the top-most bash. You can manually invoke a login shell
		# wherever you like by invoking `bash --login`
		echo "You're at a top-level or login shell. Exiting here will end the terminal session"
		# or in terse phrasing like `logout` uses:
		# echo "$0: is login shell. Use \`logout' or \`exit'"
	else
		echo "You're not at the top-level login. Exiting $(basename "$SHELL") ${$} to ${PPID}"
		exit
	fi
}
