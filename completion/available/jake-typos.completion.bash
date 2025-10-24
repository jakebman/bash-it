# shellcheck shell=bash
about-completion "Jake's custom tool for common typos in common and jake-custom scripts"
# Load before other completions - typos are a fallback, so if there is a "real" command,
# we want to allow its completion to overwrite our completion setting here.
# BASH_IT_LOAD_PRIORITY: 349

# A 'canary' commmand from the jake-typos plugin. This implies that all other commands and environment variables also exist.
if ! _command_exists _typos-helper; then
	_log_error "Please enable the typos plugin in order to enable completion for typos"
	return
fi

function _list_typo_names {
	# https://stackoverflow.com/questions/948008/linux-command-to-list-all-available-commands-and-aliases
	# List all functions and aliases.
	# (Ignore builtins, binaries, builtins, and keywords)
	_typos-helper 'compgen -A function -a'
}

# TODO: This doesn't work for typo-functions
function _complete_typo {
	if ! [ -f "$BASH_IT_TYPOS_FILE" ]; then
		return
	fi

	# Exfiltrate COMPREPLY from within a subshell
	# See projects-CDPATH for this pattern working elsewhere
	# We should only source BASH_IT_TYPOS_FILE in a subshell or subprocess
	mapfile -t -d '' COMPREPLY < <(
		source "$BASH_IT_TYPOS_FILE"

		# _complete_alias needs to be the completion function for $1, otherwise
		# it would be afraid of improperly restoring the context when it unmasks
		# the alias.
		# We're in a subshell - we don't care.
		complete -F _complete_alias "$1"
		_complete_alias "$@"

		printf "%s\0" "${COMPREPLY[@]}" | sort --zero-terminated | uniq --zero-terminated
	)

	# Corner case: mapfile will always be able to read a single empty string from an empty result.
	if [[ 1 -eq "${#COMPREPLY[@]}" && -z "${COMPREPLY[0]}" ]]; then
		COMPREPLY=()
	fi
}

function _complete_implicit-git_typo {
	mapfile -t -d '' COMPREPLY < <(
		alias "${1}=git ${1}"
		complete -F _complete_alias "$1"
		_complete_alias "$@"
		printf "%s\0" "${COMPREPLY[@]}" | sort --zero-terminated | uniq --zero-terminated
	)

	# Corner case: mapfile will always be able to read a single empty string from an empty result.
	if [[ 1 -eq "${#COMPREPLY[@]}" && -z "${COMPREPLY[0]}" ]]; then
		COMPREPLY=()
	fi
}

function _fallback_to_typos {
	if COMPREPLY=( $(compgen -c -- "$2") ); then
		# a normal command exists. Just pass it up
		return
	fi
	# "Naturally" return with compgen's result
	# TODO: since all the results here are typos, it would be real dumb to make me choose between two bad spellings of the same command.
	COMPREPLY=( $(compgen -W "$(_list_typo_names)" "$2") )
}

function _add_typo_completions_without_overriding_existing {
	local command
	for command in $(_list_typo_names); do
		# Don't overwrite any existing completion with my typos
		# I'm pretty certain the bash_completion stuff procs before bash-it
		if complete -p "$command" &>/dev/null; then
			_log_debug "Not creating typo completion for ${command}"
		else
			complete -F _complete_implicit-git_typo "$command"
		fi
	done
	for command in $(git list-all-commands); do # NB: Jake-specific command
		# Don't overwrite any existing completion. Some git commands pun with existing real commands
		# Ex: `rm` vs `git rm`
		if complete -p "$command" &>/dev/null; then
			_log_debug "Not creating git-fallback completion for ${command}"
		else
			complete -F _complete_implicit-git_typo "$command"
		fi
	done
}

# TODO: there's an enhancement opportunity to allow for dynamic completion loading. From `man bash`:
#       There  is  some  support  for dynamically modifying completions.  This is most useful when
#       used in combination with a default completion specified with complete -D.   It's  possible
#       for  shell functions executed as completion handlers to indicate that completion should be
#       retried by returning an exit status of 124.  If a shell function returns 124, and  changes
#       the  compspec associated with the command on which completion is being attempted (supplied
#       as the first argument when the function is  executed),  programmable  completion  restarts
#       from  the beginning, with an attempt to find a new compspec for that command.  This allows
#       a set of completions to be built dynamically as completion is attempted, rather than being
#       loaded all at once.
#
#       For instance, assuming that there is a library of compspecs, each kept in  a  file  corre‐
#       sponding  to the name of the command, the following default completion function would load
#       completions dynamically:
#
#       _completion_loader()
#       {
#            . "/etc/bash_completion.d/$1.sh" >/dev/null 2>&1 && return 124
#       }
#       complete -D -F _completion_loader -o bashdefault -o default

_add_typo_completions_without_overriding_existing
# TODO: typo completion could clobber existing builtin completions, but that's less likely
complete -F _complete_typo $(_list_typo_names)
complete -F _fallback_to_typos -I -c # -c means we're completing commands, so ./foo/bar completes properly
