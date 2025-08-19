# shellcheck shell=bash
cite about-plugin
about-plugin "Jake's custom tool for common typos in common and jake-custom scripts"

# Essentially "A bash file that you source in bash's command_not_found_handle context. It creates commands that are typos of other commands."
# TODO: maybe we expose the command to there, but it *should* be static, please. Aliases. Functions. Boring stuff.
: ${BASH_IT_TYPOS_FILE:=${XDG_CONFIG_HOME:-${HOME}/.config}/bash-it/typos.bash}
# cd can't be handled by command_not_found_handle. We'll just source these inline
: ${BASH_IT_BUILTIN_TYPOS_FILE:=${XDG_CONFIG_HOME:-${HOME}/.config}/bash-it/builtin-typos.bash}

if [ -f "${BASH_IT_BUILTIN_TYPOS_FILE}" ]; then
	source "${BASH_IT_BUILTIN_TYPOS_FILE}"
fi

if ! [ -f "${BASH_IT_TYPOS_FILE}" ]; then
	if [ -f "${BASH_IT_BUILTIN_TYPOS_FILE}" ]; then
		_log_debug "No typos file at ${BASH_IT_TYPOS_FILE} - only builtin typos found"
	else
		_log_error "No typo files found. Consider setting \$BASH_IT_TYPOS_FILE and \$BASH_IT_BUILTIN_TYPOS_FILE"
	fi
	return
fi

# https://mharrison.org/post/bashfunctionoverride/
# NB: this won't cover recursive functions properly
function save_function {
	local ORIG_FUNC=$(declare -f $1)
	local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
	eval "$NEWNAME_FUNC"
}

function alias_value {
	about "the expanded value of an alias. Probably unsafe and buggy"
	# TODO: this doesn't do well if the alias value has single quotes in it
	local name=$1
	if ! alias "$name" &> /dev/null; then
		return 1 # failed
	fi

	local value=$(alias "$name" | sed -E -e "s/^alias( --)? $name=//g")
	# TODO: If we don't do this, the function doesn't do well if the alias value has single quotes in it
	# However, as-is, this is potentially very unsafe. I can't even guess why. But eval is scary.
	eval echo "${value}"
}

save_function command_not_found_handle _ububtu_command_not_found_handle
function command_not_found_handle {
	local -a args=("${@:2}")
	local name=$1

	if [ -f "${BASH_IT_TYPOS_FILE}" ] &&
		source "${BASH_IT_TYPOS_FILE}" &&
		type -t "$name" &>/dev/null; then
		# This is so much easier to phrase as a success chain instead of negations
		: # success - we'll continue.
	else
		# we don't have a typo entry for this word. Follow the old path
		_ububtu_command_not_found_handle "$@"
		return
	fi

	local a_value
	if a_value=$(alias_value "$name" 2> /dev/null); then
		# Typo was implemented as an alias
		>&2 echo "Simple typo: $a_value ${args[@]@Q}"
	else
		>&2 echo "Complex typo: $name ${args[@]@Q}"
	fi

	# TODO: can I get a printed bash stack trace?
	_log_debug "found typo solution '$(type "$name")' for '$name'"

	local - # local set -o stuff
	# TODO: Check if the outer bash is interactive
	shopt -qs expand_aliases
	# the arguments are 'quoted in a format that can be reused as input.' per Bash's @ "Parameter transformation"
	# @Q and :2 cannot be combined in the same substitution, though I didn't try very hard - this is far more readable
	# NB: this might be able to accomplished cleaner following the suggestion here:
	# https://unix.stackexchange.com/questions/444946/how-can-we-run-a-command-stored-in-a-variable#:~:text=in%20the%20end.-,Using%20an%20array%3A,-Arrays%20allow%20creating
	# (but it might be true that the quoted first argument defeats alias expansion)
	eval "$name" "${args[@]@Q}"
}


function _typos-helper {
	local command=$1
	# NB: this will not squawk if either file is missing.
	BASH_ENV=<(cat "$BASH_IT_TYPOS_FILE" "$BASH_IT_BUILTIN_TYPOS_FILE") bash -r -c "$command"
}

function typos {
	(
		# aliases first
		_typos-helper 'alias -p' | sort
		# functions last
		_typos-helper 'declare -f'
	) | pager
}

function typo {
	vim "${BASH_IT_TYPOS_FILE}"
}

function typo-builtin {
	vim "${BASH_IT_BUILTIN_TYPOS_FILE}"
}
