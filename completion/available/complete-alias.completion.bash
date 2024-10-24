# shellcheck shell=bash
about-plugin "Use cykerway's complete-alias project to complete aliases"
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# From https://github.com/cykerway/complete-alias
# TODO: It'd be nice if this were bundled into the /vendor folder

# TODO: it would be nice if this didn't also complete my typos (This will definitely requre coordination... unless I just declare the typo aliases... after this code runs (`BASH_IT_LOAD_PRIORITY: 801`))
# OOPS!!!!: all that does is mean that igt doesn't get complions for commit/push/pull/etc. D'oh.

function _use_complete_alias {
	# Configuration. User can choose a folder, filename, or the whole path. Whole path wins, and its value is written back over any that it superceded
	# We use local variables to 'shadow' the missing configuration variables and 'plaster-over' their missing-ness within this function
	if [ ! -v COMPLETE_ALIAS_DIR ]; then
		local COMPLETE_ALIAS_DIR="${HOME}/.complete-alias"
	fi
	if [ ! -v COMPLETE_ALIAS_FILENAME ]; then
		local COMPLETE_ALIAS_FILENAME="complete_alias"
	fi
	if [ ! -v COMPLETE_ALIAS_FILE ]; then
		local COMPLETE_ALIAS_FILE="${COMPLETE_ALIAS_DIR}/${COMPLETE_ALIAS_FILENAME}"
	fi

	# Re-read the dir and filename back from the ultimate configuration
	COMPLETE_ALIAS_DIR="$(dirname "${COMPLETE_ALIAS_FILE}")"
	COMPLETE_ALIAS_FILENAME="$(basename "${COMPLETE_ALIAS_FILE}")"

	if [[ -f "${COMPLETE_ALIAS_FILE}" ]]; then
		source "${COMPLETE_ALIAS_FILE}"

		# complete-alias cannot see into sudo commands, because the _sudo completion strips sudo from the command line
		# This helps complete-alias see into sudo-land
		# See https://github.com/cykerway/complete-alias#:~:text=why%20is-,sudo%20completion,-not%20working%20correctly
		if ! alias sudo &> /dev/null; then
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
		local ALIAS_CLONE_COMMAND="git clone git@github.com:cykerway/complete-alias.git \"\${COMPLETE_ALIAS_DIR:-${COMPLETE_ALIAS_DIR}}\""
		_log_error "please install complete-alias or point \$COMPLETE_ALIAS_FILE to the ${COMPLETE_ALIAS_FILENAME} file within the place you checked it out from"
		_log_error "You might try: ${ALIAS_CLONE_COMMAND}"
	fi
}

_use_complete_alias
