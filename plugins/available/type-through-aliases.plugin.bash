# shellcheck shell=bash
cite about-plugin
about-plugin 'allow type to see through aliases and try to find the underlying command'


function _type_with_formatting {
	command type "$@" | bat --language=bash
}

# TODO: this doesn't work with `alias foo='/a path/with spaces'`
function type {
	about 'enhance the shell builtin `type` to try and see through aliases'

	if ! [ -t 0 ] || ! [ -t 1 ]; then
		command type "$@"
		return
	fi

	case $(command type -t -- "$1") in
		alias)
			# https://askubuntu.com/a/871435/235107
			local next #="${BASH_ALIASES[$1]}"
			_type_with_formatting "$@"
			# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
			read next args <<< "${BASH_ALIASES[$1]}"
			_type_with_formatting "$next"
			;;
		*)
			_type_with_formatting "$@"
			;;
	esac
}
