_pj() {
	local CDPATH=${BASH_IT_PROJECT_PATHS}
	# Exfiltrate COMPREPLY from within the subshell
	# I use the subshell to be safe in case a different function overrides this builtin,
	mapfile -t -d '' COMPREPLY < <(
		# Prevent the _cd completion from including local dirs
		# _cd generates the ones from CDPATH, but farms out to _filedir for local or absolute dirs
		# ... pj isn't intended to operate on absolute dirs, so that's fine
		function _filedir { : ; }

		# NB: _cd was deprecated in bash-completion 2.12 for _comp_cmd_cd
		_cd "$@"

		# NB: completion condenses multiple duplicate elements into one.
		# Even if 'foo' is via quick access and ./ (and _cd generates it twice), it completes anyway.
		printf "%s\0" "${COMPREPLY[@]}" | sort --zero-terminated | uniq --zero-terminated
	)

	# Corner case: mapfile will always be able to read a single empty string from an empty result.
	if [[ 1 -eq "${#COMPREPLY[@]}" && -z "${COMPREPLY[0]}" ]]; then
		COMPREPLY=()
	fi
}

complete -F _pj -o nospace pj
complete -F _pj -o nospace pjo
