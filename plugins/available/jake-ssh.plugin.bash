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
#
# Or another from 451253 - a symlink to major ssh, named ssht or similar, plus:
# `Match Host example.com exec "test $_ = $HOME/bin/ssht"`

function _ssh_remote_bashrc() {
	(
		cat <<-INTERPOLATING_HEREDOC
			export LESS=${LESS@Q} # Interpolated value of LESS env variable from the ssh-invoking machine
		INTERPOLATING_HEREDOC

		cat <<-'NONINTERPOLATING_HEREDOC'
			function hgrep {
				history |
					grep --color=always "$@" |
					less --RAW-CONTROL-CHARS +G
			}
			if !type vim &>/dev/null; then
				function vim {
					vi "$@"
				}
			fi

			# Permit plugin export
			function about-plugin {
				:
			}
		NONINTERPOLATING_HEREDOC

		cat "${BASH_IT}/plugins/available/jake-cdd.plugin.bash"

		echo 'source ~/.bashrc || echo "no bashrc file on $HOSTNAME"'

	) | bat -p --language Bash
}

function _ssh_additional_config() {
	# TODO: additional cleanup might be possible by using a custom --init-file to bash instead:
	# `bash --init-file <(echo "ls; pwd")`
	# See: https://serverfault.com/questions/368054/run-an-interactive-bash-subshell-with-initial-commands-without-returning-to-the
	echo "Host *"
	echo "RequestTTY=yes"
	# Nominally, ssh wants RemoteCommand all on one line. I want more lines than that, for readability.
	# So, we're pushing the contents of _ssh_remote_bashrc through base64 to the remote system
	echo "RemoteCommand=echo '$(_ssh_remote_bashrc | shfmt --minify | base64 -w0)' | base64 --decode >/tmp/jake-ssh-bashrc; bash --rcfile /tmp/jake-ssh-bashrc --login -i"
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
