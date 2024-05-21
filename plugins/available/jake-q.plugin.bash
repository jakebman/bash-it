# shellcheck shell=bash
about-plugin "q - an exit that doesn't exit your login shell (this overrides the general q alias)"
#NB: this is almost exactly the opposite behavior of bash's `logout` builtin

function _q-describe-parent() {
	about "figure out what the parent process is, describing it. Fail if it's a differen owner than this process"
	local user cmd
	local output

	output="$(ps --no-headers -o "ruser comm" --pid "$PPID" 2>&1)"
	if [[ "$?" -ne 0 ]]; then
		printf "Unable to find parent via PPID %s:%s\n" "$PPID" "$output" >&2
		echo "[unknown parent]"
		return 1
	fi

	read user cmd <<< "$output"

	# TODO: this still might not be right
	if [[ "x${user}" = "x${USER}" ]]; then
		printf "%s, owned by you" "$cmd"
		return 0 # ownership is the same - no concerns about braining wrong
	else
		printf "%s, owned by %s" "$cmd" "$user"
		printf ", because it has a different owner than this process (%s)" "$USER"
		return 1 # ownership is different. User should be aware of this
	fi
}

unalias q
function q() {
	local parent_description
	if shopt -q login_shell; then
		# NB: this isn't *necessarily* the top-most bash. You can manually invoke a login shell
		# wherever you like by invoking `bash --login`
		echo "You're at a top-level or login shell. Exiting here will end the terminal session"
		echo "Heading back to \$HOME, like you might want"
		cd ~
		# or in terse phrasing like `logout` uses:
		# echo "$0: is login shell. Use \`logout' or \`exit'"
	elif parent_description=$(_q-describe-parent); then
		echo "Exiting to parent ${parent_description}"
		exit
	else
		echo "Not automatically exiting to ${parent_description}. Use \`exit' to exit to it"
		return 1
	fi
}
