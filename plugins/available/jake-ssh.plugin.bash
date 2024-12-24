# shellcheck shell=bash
about-plugin 'A not-necessarily-good idea to forward bash functions and environment variables on (poor heuristic of) interactive ssh sessions'


function _ssh_additional_config() {
	echo "Host *"
	echo "RequestTTY=yes"
	# Nominally, ssh wants RemoteCommand all on one line. I want more lines than that, for readability.
	# So, we'll pass it through a comment removal and translation of newlines to semicolons and call it good.
	cat <<-TAB-IGNORING_HEREDOC | sed 's/#.*//g' | tr "\n" ';' | sed -E 's/;+/;/g'
	RemoteCommand= \
	export LESS=${LESS@Q} # less env variable from the current host is used, processed for being input
	function hgrep { history | grep --color=always "\$@" | less +G; }
	export -f hgrep
	bash -il
	TAB-IGNORING_HEREDOC
}

function ssh() {
	if [ "$#" -ne 1 ] || [ x"$1" == x-* ]; then
		command ssh "$@"
		return
	fi

	# We have exactly one argument, not beginning with a dash. Probably a hostname.
	# Let's do wild stuff!
	local CONF_FILE
	CONF_FILE=$(mktemp jake-ssh-config-for-interactive-shell-XXXXX --tmpdir)
	trap 'rm "$CONF_FILE"' RETURN # Remove temp file and don't pollute /tmp
	cat ~/.ssh/config >>"$CONF_FILE"
	_ssh_additional_config >>"$CONF_FILE"
	command ssh -F "$CONF_FILE" "$@"
}
