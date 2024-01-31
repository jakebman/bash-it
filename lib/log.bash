# shellcheck shell=bash
#
# A collection of logging functions.

# Declare log severity levels, matching syslog numbering
: "${BASH_IT_LOG_LEVEL_FATAL:=1}"
: "${BASH_IT_LOG_LEVEL_ERROR:=3}"
: "${BASH_IT_LOG_LEVEL_WARNING:=4}"
: "${BASH_IT_LOG_LEVEL_ALL:=6}"
: "${BASH_IT_LOG_LEVEL_INFO:=6}"
: "${BASH_IT_LOG_LEVEL_TRACE:=7}"
readonly "${!BASH_IT_LOG_LEVEL_@}"

function _bash-it-log-prefix-by-path() {
	local component_path="${1?${FUNCNAME[0]}: path specification required}"
	local without_extension component_directory
	local component_filename component_type component_name

	# get the directory, if any
	component_directory="${component_path%/*}"
	# drop the directory, if any
	component_filename="${component_path##*/}"
	# strip the file extension
	without_extension="${component_filename%.bash}"
	# strip before the last dot
	component_type="${without_extension##*.}"
	# strip component type, but try not to strip other words
	# - aliases, completions, plugins, themes
	component_name="${without_extension%.[acpt][hlo][eimu]*[ens]}"
	# Finally, strip load priority prefix
	component_name="${component_name##[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR:----}"}"

	# best-guess for files without a type
	if [[ "${component_type:-${component_name}}" == "${component_name}" ]]; then
		if [[ "${component_directory}" == *'vendor'* ]]; then
			component_type='vendor'
		else
			component_type="${component_directory##*/}"
		fi
	fi

	# shellcheck disable=SC2034
	BASH_IT_LOG_PREFIX="${component_type:-lib}: $component_name"
}

function _has_colors() {
	# Check that stdout is a terminal, and that it has at least 8 colors.
	[[ -t 1 && "${CLICOLOR:=$(tput colors 2> /dev/null)}" -ge 8 ]]
}

function _bash-it-timestamp() {
	if [[ "${BASH_IT_LOG_INCLUDE_TIMESTAMP:-true}" = 'false' ]]; then
		# disabled by user choice
		return
	elif [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_INFO?}" ]]; then
		echo "$EPOCHREALTIME: "
	fi
}

function _bash-it-log-message() {
	: _about 'Internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix'
	: _param '1: color of the message'
	: _param '2: log level to print before the prefix'
	: _param '3: message to log'
	: _group 'log'

	local prefix="${BASH_IT_LOG_PREFIX:-default}"
	local color="${1-${echo_cyan:-}}"
	local level="${2:-TRACE}"
	# shellcheck disable=SC2155
	local timestamp="$(_bash-it-timestamp)"
	local message="${timestamp}${level%: }: ${prefix%: }: ${3?}"
	if _has_colors; then
		printf '%b%s%b\n' "${color}" "${message}" "${echo_normal:-}"
	else
		printf '%s\n' "${message}"
	fi
}

function _log_stacktrace() {
	: _about 'prints the bash function calls arriving at the current _log_stacktrace invocation'
	: _param '1: formatting option. Either "--flat" for "[a, b, c]" style, "--newlines" to set each entry on its own line within another string (like the message printed by _log_trace), or "--stdout" (the default) for entries on separate lines, but without the leading empty line'
	: _group 'log'

	# --stdout style. First entry has a tab in front. Newline+tab between all, and a final newline at the end
	# Even though these strings have trusted value, we'll still use printf "%s" to print them, for safety
	# (and because shellcheck yells at us otherwise)
	local prefix="\t"
	local suffix="\n"
	local delimiter="\n\t"

	if [[ "--flat" == "$1" ]]; then
		prefix="["
		suffix="]"
		delimiter=", "
	elif [[ '--newlines' == "$1" ]]; then
		prefix="\n\t"
	fi

	printf "%s" "$prefix"

	local len=${#BASH_LINENO[@]}
	local index
	# TODO: we could start index at 1 to ignore the current _log_stacktrace invocation. If so, then update the _about section above too
	# I'm using zero here to have all the debug cards on the table
	for ((index = 0; index < len; index++)); do
		printf "%s:%s(%d)" "${BASH_SOURCE[${index}]}" "${FUNCNAME[${index}]}" "${BASH_LINENO[${index}]}"
		if ((index < len - 1)); then
			printf "%s" "$delimiter"
		fi
	done

	printf "%s" "$suffix"
}

function _log_trace() {
	: _about 'log a debug message with stack trace by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_TRACE'
	: _param '1: message to log'
	: _example '$ _log_trace "Failed to take action. Please debug me"'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_TRACE?}" ]]; then
		_bash-it-log-message "${echo_green:-}" "TRACE: " "${1} $(_log_stacktrace --newlines)"
	fi
}

function _log_debug() {
	: _about 'log a debug message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_INFO'
	: _param '1: message to log'
	: _example '$ _log_debug "Loading plugin git..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_INFO?}" ]]; then
		_bash-it-log-message "${echo_green:-}" "DEBUG: " "$1"
	fi
}

function _log_warning() {
	: _about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING'
	: _param '1: message to log'
	: _example '$ _log_warning "git binary not found, disabling git plugin..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_WARNING?}" ]]; then
		_bash-it-log-message "${echo_yellow:-}" " WARN: " "$1"
	fi
}

function _log_error() {
	: _about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR'
	: _param '1: message to log'
	: _example '$ _log_error "Failed to load git plugin..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_ERROR?}" ]]; then
		_bash-it-log-message "${echo_red:-}" "ERROR: " "$1"
	fi
}
