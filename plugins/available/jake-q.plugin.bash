# shellcheck shell=bash
about-plugin "q - an exit that doesn't exit your login shell (this overrides the general q alias)"
#NB: this is almost exactly the opposite behavior of bash's `logout` builtin

# inspired by max-manwidth
: ${MAX_KIROWIDTH:=100}

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

function _kiro-cli-sessions {
	about "List the recent kiro sessions. TODO: fzf integration"
	kiro-cli chat --list-sessions --format json \
		| jq --raw-output '.[0].sessions[:5][] |
				"",
				"# (\(.source|ascii_upcase)) \(.title)",
				"    kiro-cli chat --resume-id \(.sessionId)"' \
		| bat --language=Markdown
}
function _kiro-cli-sessions-picker {
	about "List the recent kiro sessions via fzf integration"
	kiro-cli chat --list-sessions --format json \
		| jq --raw-output '.[0].sessions[] | "\(.sessionId)\t\(.title) (\(.source))"' \
		| fzf --delimiter="\t" \
			--ansi \
			--exit-0 \
			--select-1 \
			--no-sort \
			--reverse \
			--wrap \
			--with-nth 2.. \
			--history "${JAKE_KIRO_HISTORY_FILE:-${XDG_STATE_HOME:-${HOME}/.local/state}/jake-j/kiro-history}" \
			--header "Ctrl+Space to preview" \
			--bind "ctrl-space:execute(kiro-cli chat --resume-id {1} </dev/tty >/dev/tty)" \
			--bind "q:abort" \
			--bind "change:unbind(q)" \
			--bind "backward-eof:rebind(q)" \
			--bind "enter:become(kiro-cli chat --resume-id {1} </dev/tty >/dev/tty)"
}
function _kiro-cli-once {
	about 'Run a single instance query to kiro; can use multiple bare words because of \$*'
	kiro chat --no-interactive "$*"
	# TODO: get the session id printed via _kiro-cli-sessions
}

if _command_exists kiro-cli; then
	function kiro {
		if ((COLUMNS > MAX_KIROWIDTH)); then
			local STTY_SAVED=$(stty --save)
			stty columns "$MAX_KIROWIDTH"
		fi
		case "${1-DEFAULT}" in
			debug | settings | setup | update | diagnostic | \
				init | theme | issue | login | logout | whoami | profile | \
				user | doctor | launch | quit | restart | integrations | \
				translate | dashboard | chat | mcp | inline | agent | acp | \
				help | -* | DEFAULT)
				# known kiro command (or no command at all; or "DEFAULT", which would be odd(?), but works)
				# List generated from `kiro-cli --help-all`
				kiro-cli "$@"
				;;
			session-picker | sessions-picker | \
				session-chooser | sessions-chooser)
				shift
				_kiro-cli-sessions-picker "$@"
				;;
			sessions)
				shift
				_kiro-cli-sessions "$@"
				;;
			once)
				shift # to remove 'once'
				;&    # FALL-THROUGH!!!!
			*)
				_kiro-cli-once "$@"
				;;
		esac
		if [ -v STTY_SAVED ]; then
			# Restore previous stty settings
			stty "$STTY_SAVED"
		fi
	}
	alias Q=kiro
	alias kiro-cli=kiro
else
	# Q can simply just be a safe quit
	function Q {
		echo "Heading back to \$HOME, like you might want"
		echo "But probably please install kiro-cli"
		if [ "x$PWD" != "x$HOME" ]; then
			cd ~
		fi
	}
fi

unalias q
function q() {
	local parent_description
	if [[ "$#" -ne 0 ]]; then
		# Trying to run a q/kiro-cli command
		Q "$@"
	elif shopt -q login_shell; then
		# NB: this isn't *necessarily* the top-most bash. You can manually invoke a login shell
		# wherever you like by invoking `bash --login`
		echo "You're at a top-level or login shell. Exiting here will end the terminal session"
		Q "$@"
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
