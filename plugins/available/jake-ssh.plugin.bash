# shellcheck shell=bash
about-plugin 'A not-necessarily-good idea to forward bash functions and environment variables on (poor heuristic of) interactive ssh sessions'


# I couldn't find a better way to solve this problem.
# You can choose only to proc some ssh_config lines on ssh (and not on scp) via `Match exec "test $_ = /usr/bin/ssh"`
# See https://unix.stackexchange.com/questions/451253/how-to-configure-ssh-with-a-remotecommand-only-for-interactive-sessions-i-e-wi
# But I can't find a way to only set RemoteCommand if a

# TODO: this might be easier if it's implemented as
# * a funciton like:
#	function ssh {
#		if exactly one non-flag arugment:
#			export SSH_IS_INTERACTIVE= # even an empty value is fine
#			# Optionally, re-generate config-but-only-for-interactive-shells?
#		fi
#		command ssh "$@"
#		}
# * a ~/.ssh/config-but-only-for-interactive-shells containing the output from _ssh_additional_config
# * an entry in ~/.ssh/config of:
#	Match exec 'test -v SSH_IS_INTERACTIVE'
#		# DOCUMENT THE HECK OUT OF THIS!
#		Include config-but-only-for-interactive-shells
# Thanks to https://news.ycombinator.com/item?id=23027097 for it
#
# Also, there's another option: https://github.com/atteo/uberbin/blob/master/ssh-executed-with-command
# proposes a script `ssh-executed-with-command` that enables `Match exec "ssh-executed-with-command"`
# by walking up the $PPIDs of itself until it finds an `ssh` command. Then it checks the commandline
# of that command for any "unrecognized" command options, which are "probably" commands to run on the remote
# (This seems a productionized version of https://unix.stackexchange.com/questions/451253/how-to-configure-ssh-with-a-remotecommand-only-for-interactive-sessions-i-e-wi)

function _ssh_additional_config() {
	echo "Host *"
	echo "RequestTTY=yes"
	# Nominally, ssh wants RemoteCommand all on one line. I want more lines than that, for readability.
	# So, we'll pass it through a comment removal and translation of newlines to semicolons and call it good.
	# TODO: this is a poor idea - we're applying regexes to a bash string. I'd like to refactor this so it's
	# using proper bash-code-string handling
	cat <<-TAB-IGNORING_HEREDOC | sed 's/#.*//g' | tr "\n" ';' | sed -E -e 's/;+/;/g' -e 's/\{;/\{ /g'
	RemoteCommand=\
		export LESS=${LESS@Q} # less env variable from the current host is used, processed for being input
		function hgrep { history | grep --color=always "\$@" | less --RAW-CONTROL-CHARS +G; }
		if !type vim &>/dev/null; then \
			function vim {
				vi "\$@"
			}
			export -f vim
		fi
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
