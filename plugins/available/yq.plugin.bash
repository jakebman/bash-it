#! /bin/bash

function _yq-filter {
	about '$YQ_FILTER falls back to $JQ_FILTER, which falls back to "." That is unweildy. Use this method instead.'
	printf "%s" "${YQ_FILTER:-${JQ_FILTER:-.}}"
}

function _yq-ify {
	# TODO: try and actually respect the parameter orders of our parameters
	# and figure out which is actually supposed to be the argument files
	about "use \$YQ_FILTER to choose a smaller section of the files to compare!"
	local cmd="$1"
	local left="$2"
	local right="$3"
	local filter="$(_yq-filter)"
	shift 3
	"$cmd" "$@" <(yq -S "$filter" < "$left") <(yq -S "$filter" < "$right")
}

alias yqdiff="_yq-ify diff"
alias yqvimdiff="_yq-ify vimdiff"
alias vimyqdiff="_yq-ify vimdiff"

_command_exists delta && alias yqdelta="_yqify delta"

function yqless {
	local args

	if [[ $# -eq 0 ]] || [[ -f "$1" ]]; then
		# If the user doesn't specify a filter as the first argument,
		# which means:
		# * no arguments (presume STDIN) or
		# * first argument is actually a file
		# assume they wanted to use $YQ_FILTER
		args+=("$(_yq-filter)")
	fi

	args+=("$@")
	if [ -t 1 ]; then
		local -
		set -o pipefail
		command yq "${args[@]}" | less --RAW-CONTROL-CHARS # Raw isn't necessary if we're not coloring output, but it doesn't *hurt* either
	else
		command yq "${args[@]}"
	fi
}

function yqgrep {
	about "grep for content in files, but implicity apply YQ_FILTER to the files we're grepping"
	echo "TODO, sorry"
	false
}
