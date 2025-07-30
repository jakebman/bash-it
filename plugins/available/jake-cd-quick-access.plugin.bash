# shellcheck shell=bash
about-plugin 'Allow certain folders to always remain valid `cd` targets, from anywhere (as if their parent dir is in CDPATH)'

# Implementation note: we accomplish this by combining two independent mechanisms:
# 1. Creating a special quick-access folder, with symlinks to chosen always-valid cd targets. That folder goes on CDPATH
# 2. Change cd so any single-word target that doesn't exist from `.` gets an implicit -P

# "Append the quick-access folder to the cd path"
# Notably, this also automagically creates CDPATH with the initial "." entry, because
# "A null directory name is the same as the current directory", per `help cd`
CDPATH+=":${XDG_CONFIG_HOME:-${HOME}/.config}/cd/quick-access"

function _cd-to-single-completion {
	about 'cd, but if it fails, try auto-completing the last argument word'
	if builtin cd "$@" 2>/dev/null; then
		return # propagates success. Nothing else to do.
	fi

	if [[ "$#" -eq 0 ]]; then
		# No arguments. Not a hint we could help. Bail.
		# cd had an error that we sent to /dev/null. Let's let it try again, to show the error to the user
		builtin cd "$@"
		return # returns the exit code of the previous command
	fi

	# Manually set up the completion environment like documented in bash's manpage
	local -a COMPREPLY COMP_WORDS
	local COMP_CWORD COMP_KEY COMP_LINE COMP_POINT COMP_TYPE
	# COMP_WORDBREAKS participates, but we have no reason to change its value
	COMP_WORDS=(cd "$@")
	COMP_LINE="${COMP_WORDS[@]}"
	(( COMP_CWORD = ${#COMP_WORDS[@]} - 1 ))
	COMP_POINT=${#COMP_LINE}

	local -a completion_arg_list
	# The args to a completion function are:
	# 1) name of the command whose arguments are being completed
	# 2) the  word  being completed
	# 3) the word preceding the word being completed on the current command line
	completion_arg_list=("${COMP_WORDS[0]}" "${COMP_WORDS[-1]}" "${COMP_WORDS[-2]}")


	# Exfiltrate COMPREPLY from within the subshell
	# I use the subshell to be safe in case a different function overrides this builtin,
	# but it's also nice for the `... | sort | uniq` phrasing
	mapfile -t -d '' COMPREPLY < <(
		# We're not in a completion context, so when _cd asks the completion mechanisms
		# to handle these results like filenames...
		# 1) The completion mechanism isn't there to listen, but...
		# 2) It doesn't matter, because we're taking the values directly from COMPREPLY, and
		#       not trying to splort a chosen value from there back onto a string command line
		function compopt { : ; }

		# NB: _cd was deprecated in bash-completion 2.12 for _comp_cmd_cd
		_cd "${completion_arg_list[@]}"

		# NB: completion condenses multiple duplicate elements into one.
		# Even if 'foo' is via quick access and ./ (and _cd generates it twice), it completes anyway.
		printf "%s\0" "${COMPREPLY[@]}" | sort --zero-terminated | uniq --zero-terminated
	)

	# Corner case: mapfile will always be able to read a single empty string from an empty result.
	if [[ 1 -eq "${#COMPREPLY[@]}" && -z "${COMPREPLY[0]}" ]]; then
		COMPREPLY=()
	fi

	case "${#COMPREPLY[@]}" in
		0)
			# cd had an error that we sent to /dev/null.
			# We don't have a guess at what to change.
			# Let's let `cd` try again, to show the error to the user
			builtin cd "$@"
			;;
		1)
			# Try again, with all but the last argument, followed by the only completion for the last argument
			builtin cd "${@:1:$# - 1}" "${COMPREPLY[0]}"
			;;
		*)
			# Too many things that might fix this.
			builtin cd "$@" 2> >(sed -E "s/(No such file or directory)/\1.\n${FUNCNAME}: Enhanced guessing behavior is also unwilling to guess between ${#COMPREPLY[@]} completions/" >&2)
			;;
	esac
}

# TODO: (another plugin?) to respect a -p flag to cd, which `mkdir -p`'s its argument, then my cdp function can just alias that instead
function cd {
	about 'normal `cd`, but non-$CWD entries (and cdable_vars) get an implicit -P to follow symlinks'
	if [[ "$#" -eq 1 ]] && [[ - != "$1" ]] && ! [[ -d "$1" ]]; then
		# Shim: I'm basically assuming all symlinks contained in non-$CWD entries in CDPATH are "less canonical"
		# than their targets.
		# (but the folder `-` doesn't ususally exist, so we special-case that)
		_cd-to-single-completion -P "$@"
	else
		_cd-to-single-completion "$@"
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
