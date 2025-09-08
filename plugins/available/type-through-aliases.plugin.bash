# shellcheck shell=bash
cite about-plugin
about-plugin 'allow type to see through aliases and try to find the underlying command'


function _type_with_typos {
	about '`command type`, but aware of typos'
	if command type "$@" 2>/dev/null; then
		# Happy path! Successfully found something
		return
	fi
	local err=$?

	# Don't check for typos if nobody declared any typos
	if ! [ -f "$BASH_IT_TYPOS_FILE" ]; then
		return $err
	fi
	# TODO: respond to `-t` queries
	(
		set -o pipefail -o errexit
		source "$BASH_IT_TYPOS_FILE"
		command type "$@" |
			sed 's/is aliased to/is a typo of/g'
	)
}

if _command_exists bat; then
	function _type_with_formatting {
		local -
		set -o pipefail
		_type_with_typos "$@" | bat --language=bash
	}
else
	function _type_with_formatting {
		_type_with_typos "$@"
	}
fi

_command_exists shfmt || return

# TODO: when a resolved alias is to a fully-qualified path, there's no need to follow it
# TODO: when a resolved alias is to itself (alias sudo='sudo '), the alias shouldn't be checked (type -P?)
# TODO: what about printing additional info if a function shadows an executable file while we're at it
function type {
	about 'enhance the shell builtin `type` to try and see through aliases'

	if ! [ -t 0 ] || ! [ -t 1 ]; then
		_type_with_typos "$@"
		return
	fi

	# TODO: parse the flags and args. Guessing $1 is wrong.
	case $(command type -t -- "$1") in
		alias)
			# https://askubuntu.com/a/871435/235107
			local next #="${BASH_ALIASES[$1]}"
			_type_with_formatting "$@"
			# shfmt seems to be my best parser to find the first word of the first command in the alias
			# TODO: consider recursing into *all* statements in `alias a='foo; bar; baz'`. Use read -d "\0" and jq's --raw-output0
			next=$(shfmt <<< "${BASH_ALIASES[${1}]}" --to-json | jq --raw-output '.Stmts[0].Cmd.Args[0].Parts[0].Value')
			_type_with_formatting "$next"
			;;
		*)
			_type_with_formatting "$@"
			;;
	esac
}
