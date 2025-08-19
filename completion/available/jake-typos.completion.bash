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

complete -F _complete_typo $(_list_typo_names)
