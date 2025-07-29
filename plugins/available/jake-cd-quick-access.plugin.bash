# shellcheck shell=bash
about-plugin 'Allow certain folders to always remain valid `cd` targets, from anywhere (as if their parent dir is in CDPATH)'

# Implementation note: we accomplish this by combining two independent mechanisms:
# 1. Creating a special quick-access folder, with symlinks to chosen always-valid cd targets. That folder goes on CDPATH
# 2. Change cd so any single-word target that doesn't exist from `.` gets an implicit -P

# "Append the quick-access folder to the cd path"
# Automagically, however this also creates CDPATH with the initial "." entry, because
# "A null directory name is the same as the current directory", per `help cd`
CDPATH+=":${XDG_CONFIG_HOME:-${HOME}/.config}/cd/quick-access"

function _cd-to-single-completion {
	if builtin cd "$@"; then
		return # propagates success. Nothing else to do.
	fi
	local failure=$?
	if [[ "$#" -ne 1 ]]; then
		# Not sure how to handle flags right now
		return $failure
	fi
	local single_arg="$1"
	# was deprecated in bash-completion 2.12 for _comp_cmd_cd
	(
		local -a COMPREPLY
		function _init_completion { cur="$single_arg"; prev=cd; }
		#function compopt { : ; }
		# TODO: do we need to handle _filedir -d if CDPATH is empty?
		# We do need to do something reasonable if an absolute dir, or a ..?/ is specified
		set -x
		_cd cd "$1" cd
		printf "{%s}\n" "${COMPREPLY[@]}"

		# TODO: completion condenses multiple duplicate elements into one. 'foo' is via quick access and ./, but works.
	)
}

# TODO: (another plugin?) to respect a -p flag to cd, which `mkdir -p`'s its argument, then my cdp function can just alias that instead
function cd {
	about 'normal `cd`, but non-$CWD entries (and cdable_vars) get an implicit -P to follow symlinks'
	if [[ "$#" -eq 1 ]] && [[ - != "$1" ]] && ! [[ -d "$1" ]]; then
		# Shim: I'm basically assuming all symlinks contained in non-$CWD entries in CDPATH are "less canonical"
		# than their targets.
		# (but the folder `-` doesn't ususally exist, so we special-case that)
		builtin cd -P "$@"
	else
		builtin cd "$@"
	fi
}

function _cd-generate-quick-access {
	about "You'd like something like shopt -s cdable_vars, but only selectively (also, tab-completable)"
	# NB: the _cd completion doesn't respect cdable_vars

	# https://stackoverflow.com/questions/69257739/bash-get-a-list-of-environment-variables-with-proper-handling-of-new-lines
	local i
	for i in $(compgen -A variable); do
		if [[ -d "${!i}" ]]; then
			echo "${i}=${!i}"
		fi
	done
}
