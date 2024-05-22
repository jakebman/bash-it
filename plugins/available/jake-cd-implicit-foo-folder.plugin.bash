# shellcheck shell=bash
about-plugin 'Pretend ~/foo is a valid target to cd into, from anywhere (as if its parent dir is in CDPATH)'

# TODO: this behavior could become generic ("$BASH_IT_CDPATH_ITEMS"). When it does, it is almost like `pj`, so maybe an integration becomes in-order

function cd {
	if [[ "$#" -eq 1 ]] && [[ "foo" = "$1" ]] && ! [[ -e "foo" ]]; then
		# emulate the following CDPATH behavior:
		# cd:
		# If a non-empty directory name from CDPATH is used ... and the directory change is successful,
		# the absolute pathname of the new working directory is written to the standard output.
		builtin cd ~/foo && echo ~/foo
	else
		builtin cd "$@"
	fi
}
