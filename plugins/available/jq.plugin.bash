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
  "$cmd" "$@" <(jq -S "$filter" <"$left") <(jq -S "$filter" <"$right")
}

alias jqdiff="_jq-ify diff"
alias jqvimdiff="_jq-ify vimdiff"
alias vimjqdiff="_jq-ify vimdiff"


function jqless {
	local args
	# color output so that less can see it
	# (NB/TODO: requires less to allow color control characters via -R or -r)
	args+=(--color-output)

	if [[ $# -le 1 ]] || [[ -f "$1" ]] ; then
		# If the user doesn't specify a filter as the first argument,
		# or the first argument is actually, and obviously, a file
		# assume they wanted to use $JQ_FILTER
		args+=("${JQ_FILTER:-.}")
	fi

	args+=("$@")
	jq "${args[@]}" | less
}

function jqgrep {
	about "grep for content in files, but implicity apply JQ_FILTER to the files we're grepping"
	echo "TODO, sorry"
	false
}
