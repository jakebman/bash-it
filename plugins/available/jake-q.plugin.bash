# shellcheck shell=bash
about-plugin "q - an exit that doesn't exit your login shell (this overrides the general q alias)"
#NB: this is almost exactly the opposite behavior of bash's `logout` builtin

function _q-describe-parent () {
	about "figure out what the parent process is, describing it. Fail if it's a differen owner than this process"
	local user cmd
	local output;
	if output="$(ps -o user= -o cmd= -p "$PPID")"; then
		echo "$output"
		if echo "$output" | grep -q "$USER"; then
			return 0 # safe - ownership is the same
		else
			return 1 # unsafe - ownership is different
		fi
	else
		echo "unable to find parent via PPID ${PPID}"
		return 1
	fi
}

unalias q
function q () {
	local parent_description;
	if shopt -q login_shell; then
		# NB: this isn't *necessarily* the top-most bash. You can manually invoke a login shell
		# wherever you like by invoking `bash --login`
		echo "You're at a top-level or login shell. Exiting here will end the terminal session"
		# or in terse phrasing like `logout` uses:
		# echo "$0: is login shell. Use \`logout' or \`exit'"
	elif parent_description=$(_q-describe-parent); then
		echo "Exiting to safe parent, ${parent_description}"
		exit
	else
		echo "Parent process ${parent_description}. Use \`exit' to exit to it"
	fi
}
