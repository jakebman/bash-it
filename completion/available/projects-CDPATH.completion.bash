_pj() {
	local CDPATH=${BASH_IT_PROJECT_PATHS}
	# TODO: is there a way to discover the completion for `cd` in a portable way?
	_cd "$@"
}

complete -F _pj -o nospace pj
complete -F _pj -o nospace pjo
