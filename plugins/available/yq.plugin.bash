#! /bin/bash

function _yq-ify {
	# TODO: try and actually respect the parameter orders of our parameters
	# and figure out which is actually supposed to be the argument files
	about "use \$YQ_FILTER to choose a smaller section of the files to compare!"
	local cmd="$1"
	local left="$2"
	local right="$3"
	local filter="${YQ_FILTER:-.}"
	shift 3
	"$cmd" "$@" <(yq -S "$filter" < "$left") <(yq -S "$filter" < "$right")
}

# TODO: there's an update-alternatives for jsondiff. It currently is won by this file:
# python3-jsonpatch: /usr/bin/json-patch-jsondiff
# ... Do I want to put yq's hat into the fray?
# decent info at https://dev.to/webduvet/how-to-manage-versions-using-update-alternatives-258e

alias yqdiff="_yq-ify diff"
alias yqvimdiff="_yq-ify vimdiff"
alias vimyqdiff="_yq-ify vimdiff"

_command_exists delta && alias yqdelta="_yqify delta"

function yqless {
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
		# assume they wanted to use $YQ_FILTER
		args+=("${YQ_FILTER:-.}")
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

if _command_exists iyq; then
	function iyq {
		local temp=$(mktemp iyq-YQ_FILTER_RESULT-XXXXXXXXXX --tmpdir)
		trap 'rm "$temp"' RETURN
		# Alas, a here-string would be more verbose as an argument to -f. Something like: `/dev/fd/23 23<<<"$YQ_FILTER"`
		# See https://unix.stackexchange.com/questions/505828/how-to-pass-a-string-to-a-command-that-expects-a-file
		command iyq -f <(printf "%s" "${YQ_FILTER:-.}") "$@" 2>"$temp"
		local return=$?
		local filter=$(<"$temp")

		if [ 0 != "$return" ]; then
			>&2 echo "iyq failure. Not setting YQ_FILTER to ${filter@Q}"
		elif [ -z "$filter" ]; then
			>&2 echo "Empty result query. Not setting YQ_FILTER=${filter@Q}"
		else
			# NB: this still won't work in cat foo.json | iyq, which is another good reason to print the filter below
			>&2 echo "Set YQ_FILTER=${filter@Q}"

			# specifically and intentionally NOT LOCAL
			YQ_FILTER=$filter
		fi
		return $return
	}
fi

function yqgrep {
	about "grep for content in files, but implicity apply YQ_FILTER to the files we're grepping"
	echo "TODO, sorry"
	false
}
