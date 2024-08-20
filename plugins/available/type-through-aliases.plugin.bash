

function type {
	# TODO: `about` docs, recursive drilling down until no longer getting an alias
	case $(command type -t -- "$1") in
		alias)
			# https://askubuntu.com/a/871435/235107
			local next #="${BASH_ALIASES[$1]}"
			command type "$@"
			# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
			read next args <<< "${BASH_ALIASES[$1]}"
			command type "$next"
			;;
		*)
			command type "$@"
			;;
	esac
}
