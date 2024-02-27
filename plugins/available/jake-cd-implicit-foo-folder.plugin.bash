# shellcheck shell=bash
about-plugin 'auto-create a folder named foo if you cd into it'

function cd {
	if [[ "$#" -eq 1 ]] && [[ "foo" = "$1" ]] && ! [[ -f "foo" ]]; then
		mkdir foo
	fi
	builtin cd "$@"
}

