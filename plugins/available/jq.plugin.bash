#! /bin/bash

function _jq-ify {
	# TODO: try and actually respect the parameter orders of our parameters
	# and figure out which is actually supposed to be the argument files
	about "use \$JQ_FILTER to choose a smaller section of the files to compare!"
	local cmd="$1"
	local left="$2"
	local right="$3"
	local filter="${JQ_FILTER:-.}"
	shift 3
	"$cmd" "$@" <(jq -S "$filter" < "$left") <(jq -S "$filter" < "$right")
}

alias jqdiff="_jq-ify diff"
alias jqvimdiff="_jq-ify vimdiff"
alias vimjqdiff="_jq-ify vimdiff"

function jqless {
	local args

	if [ -t 1 ]; then
		# terminal output - color it
		args+=(--color-output)
	fi

	if [[ $# -eq 0 ]] || [[ -f "$1" ]]; then
		# If the user doesn't specify a filter as the first argument,
		# which means:
		# * no arguments (presume STDIN) or
		# * first argument is actually a file
		# assume they wanted to use $JQ_FILTER
		args+=("${JQ_FILTER:-.}")
	fi

	args+=("$@")
	command jq "${args[@]}" | less --RAW-CONTROL-CHARS # Raw isn't necessary if we're not coloring output, but it doesn't *hurt* either
}

function jqgrep {
	about "grep for content in files, but implicity apply JQ_FILTER to the files we're grepping"
	echo "TODO, sorry"
	false
}
