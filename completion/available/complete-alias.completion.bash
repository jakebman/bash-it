# shellcheck shell=bash
about-plugin "Use cykerway's complete-alias project to complete aliases"
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# TODO: this name doesn't autocomplete after bash-it enable completion [$name]

# From https://github.com/cykerway/complete-alias

: "${COMPLETE_ALIAS_FILE:=${HOME}/.complete-alias/complete_alias}"

if [ -f "${COMPLETE_ALIAS_FILE}" ]; then
	source "${COMPLETE_ALIAS_FILE}"
else
	_log_error "please install complete-alias from https://github.com/cykerway/complete-alias, or point \$COMPLETE_ALIAS_FILE to the complete_alias file within the place you checked it out from"
fi

complete -F _complete_alias "${!BASH_ALIASES[@]}"
