# shellcheck shell=bash
about-plugin "Use cykerway's complete-alias project to complete aliases"
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# TODO: this name doesn't autocomplete after bash-it enable completion [$name]

# From https://github.com/cykerway/complete-alias

: "${COMPLETE_ALIAS_FILE:=${HOME}/.complete-alias/complete_alias}"

if [ -f "${COMPLETE_ALIAS_FILE}" ]; then
	source "${COMPLETE_ALIAS_FILE}"
	complete -F _complete_alias "${!BASH_ALIASES[@]}"
else
	ALIAS_CLONE_COMMAND="git clone git@github.com:cykerway/complete-alias.git \"\$(dirname \"\${COMPLETE_ALIAS_FILE:-${COMPLETE_ALIAS_FILE}}\")\""
	_log_error "please install complete-alias or point \$COMPLETE_ALIAS_FILE to the complete_alias file within the place you checked it out from"
	_log_error "You might try: ${ALIAS_CLONE_COMMAND}"
	unset ALIAS_CLONE_COMMAND
fi

