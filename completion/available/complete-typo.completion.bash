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
	complete -F _complete_alias_for_typos "${!_BASH_IT_TYPOS[@]}"
}


# Named to be compatible with _complete_alias checking https://github.com/cykerway/complete-alias/blob/7f2555c2fe7a1f248ed2d4301e46c8eebcbbc4e2/complete_alias#L806
function _complete_alias_for_typos {
	_typos-load
	_complete_alias
	local ret=$?
	_typos-unload
	return $ret
}


_use_complete_typo
