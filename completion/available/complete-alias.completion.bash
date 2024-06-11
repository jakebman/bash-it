# shellcheck shell=bash
about-plugin "Use cykerway's complete-alias project to complete aliases"
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# From https://github.com/cykerway/complete-alias
# TODO: It'd be nice if this were bundled into the /vendor folder

# Configuration. User can choose a folder, filename, or the whole path. Whole path wins. We clean-back-up whatever the user left unset
COMPLETE_ALIAS_CLEANUP=(CLEANUP) # unset this variable itself
if [ ! -v COMPLETE_ALIAS_DIR ]; then
	COMPLETE_ALIAS_CLEANUP+=(DIR)
	COMPLETE_ALIAS_DIR="${HOME}/.complete-alias"
fi
if [ ! -v COMPLETE_ALIAS_FILENAME ]; then
	COMPLETE_ALIAS_CLEANUP+=(FILENAME)
	COMPLETE_ALIAS_FILENAME="complete_alias"
fi
if [ ! -v COMPLETE_ALIAS_FILE ]; then
	COMPLETE_ALIAS_CLEANUP+=(FILE)
	COMPLETE_ALIAS_FILE="${COMPLETE_ALIAS_DIR}/${COMPLETE_ALIAS_FILENAME}"
fi

# Re-read the dir and filename back from the ultimate configuration
COMPLETE_ALIAS_DIR="$(dirname "${COMPLETE_ALIAS_FILE}")"
COMPLETE_ALIAS_FILENAME="$(basename "${COMPLETE_ALIAS_FILE}")"

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
	ALIAS_CLONE_COMMAND="git clone git@github.com:cykerway/complete-alias.git \"\${COMPLETE_ALIAS_DIR:-${COMPLETE_ALIAS_DIR}}\""
	_log_error "please install complete-alias or point \$COMPLETE_ALIAS_FILE to the ${COMPLETE_ALIAS_FILENAME} file within the place you checked it out from"
	_log_error "You might try: ${ALIAS_CLONE_COMMAND}"
	unset ALIAS_CLONE_COMMAND
fi

# Don't pollute the environment - remove variables the user didn't specifically set
# TODO: This cleanup is dumb. Make the relevant variables local to a function, then call it.
# (In retrospect, that's probably why other plugins that strategy)
for _deleted_suffix in "${COMPLETE_ALIAS_CLEANUP[@]}"; do
	unset "COMPLETE_ALIAS_${_deleted_suffix}"
done
unset _deleted_suffix
