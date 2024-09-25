# shellcheck shell=bash
about-plugin "Use complete-alias completion to also complete typos. Requires complete-alias completion and typos plugin"
# Load after all aliases and completions, and *the complete-alias completion itself to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 810

# See complete-alias for more information.

function _use_complete_typo {
	if ! _command_exists _complete_alias; then
		# We need the complete-alias completion
		# TODO: a shared library tech for these two
		_log_error "Please enable complete-alias completion to use this completion"
		return 1
	fi
	if ! _command_exists _typos-load; then
		# We need the jake-typos plugin
		# TODO: a shared library tech for these two
		_log_error "Please enable the typos plugin to use this completion"
		return 1
	fi
	complete -F _complete_typo "${!_BASH_IT_TYPOS[@]}"
}

function _complete_typo {
	(
		_typos-load
		_complete_alias
	)
}


_use_complete_typo
