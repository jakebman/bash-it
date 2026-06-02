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
	"$cmd" "$@" <(jq --sort-keys "$filter" < "$left") <(jq --sort-keys "$filter" < "$right")
}

# TODO: there's an update-alternatives for jsondiff. It currently is won by this file:
# python3-jsonpatch: /usr/bin/json-patch-jsondiff
# ... Do I want to put jq's hat into the fray?
# decent info at https://dev.to/webduvet/how-to-manage-versions-using-update-alternatives-258e

alias jqdiff="_jq-ify diff"
alias jqvimdiff="_jq-ify vimdiff"
alias vimjqdiff="_jq-ify vimdiff"

_command_exists delta && alias jqdelta="_jq-ify delta"

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
	if [ -t 1 ]; then
		local -
		set -o pipefail
		command jq "${args[@]}" | less --RAW-CONTROL-CHARS # Raw isn't necessary if we're not coloring output, but it doesn't *hurt* either
	else
		command jq "${args[@]}"
	fi
}

if _command_exists ijq; then
	function ijq {
		local temp=$(mktemp ijq-JQ_FILTER_RESULT-XXXXXXXXXX --tmpdir)
		trap 'rm "$temp"' RETURN
		# Alas, a here-string would be more verbose as an argument to -f. Something like: `/dev/fd/23 23<<<"$JQ_FILTER"`
		# See https://unix.stackexchange.com/questions/505828/how-to-pass-a-string-to-a-command-that-expects-a-file
		command ijq -f <(printf "%s" "${JQ_FILTER:-.}") "$@" 2>"$temp"
		local return=$?
		local filter=$(<"$temp")

		if [ 0 != "$return" ]; then
			>&2 echo "ijq failure. Not setting JQ_FILTER to ${filter@Q}"
		elif [ -z "$filter" ]; then
			>&2 echo "Empty result query. Not setting JQ_FILTER=${filter@Q}"
		else
			# NB: this still won't work in cat foo.json | ijq, which is another good reason to print the filter below
			>&2 echo "Set JQ_FILTER=${filter@Q}"

			# specifically and intentionally NOT LOCAL
			JQ_FILTER=$filter
		fi
		return $return
	}
fi

function jqgrep {
	about "grep for content in files, but implicity apply JQ_FILTER to the files we're grepping"
	echo "TODO, sorry"
	false
}
