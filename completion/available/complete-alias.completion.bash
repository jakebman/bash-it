# shellcheck shell=bash
about-plugin "Use cykerway's complete-alias project to complete aliases"
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# From https://github.com/cykerway/complete-alias
# TODO: this can actually live in the /vendor folder
: "${COMPLETE_ALIAS_FILE:=${HOME}/.complete-alias/complete_alias}"

if [[ -f "${COMPLETE_ALIAS_FILE}" ]]; then
	source "${COMPLETE_ALIAS_FILE}"

	# complete-alias cannot see into sudo commands, because the _sudo completion strips sudo from the command line
	# This helps complete-alias see into sudo-land
	# See https://github.com/cykerway/complete-alias#:~:text=why%20is-,sudo%20completion,-not%20working%20correctly
	if ! alias sudo &>/dev/null; then
		if [[ "${COMPLETE_ALIAS_SUDO:-true}" != "true" ]]; then
			_log_debug "sudo alias support disabled"
		else
			if [[ "${COMPLETE_ALIAS_SUDO}" != "true" ]]; then # acted by default
				_log_debug "Installing sudo alias. Set \$COMPLETE_ALIAS_SUDO to true to suppress this message, or false to disable this behavior"
			fi
			alias sudo=sudo
		fi
	fi

	complete -F _complete_alias "${!BASH_ALIASES[@]}"
else
	ALIAS_CLONE_COMMAND="git clone git@github.com:cykerway/complete-alias.git \"\$(dirname \"\${COMPLETE_ALIAS_FILE:-${COMPLETE_ALIAS_FILE}}\")\""
	_log_error "please install complete-alias or point \$COMPLETE_ALIAS_FILE to the complete_alias file within the place you checked it out from"
	_log_error "You might try: ${ALIAS_CLONE_COMMAND}"
	unset ALIAS_CLONE_COMMAND
fi

