about-plugin "Easy access to the wordlist via a words command, plus NYT puzzle solvers which use it"

function words {
	about 'print the word list, paged. Arguments are ack filters on a word list (flags apply to the next non-flag argument, which is assumed to be a regex). If stdin is not a terminal, it is used in lieu of the ${WORDLIST:/usr/share/dict/words}'
	# Implementation note: this is *incredibly recursive*

	# Base cases
	if [[ -t 0 ]]; then
		# First invocation: take wordlist implicitly if no other stdin is specified
		cat "${WORDLIST:-/usr/share/dict/words}" | words "$@"
		return
	elif [[ "$#" -eq 0 ]]; then
		# Last invocation: all the filters from all of "$@" have applied.
		# We unconditionally invoke the pager and assume it'll not page unless necessary
		pager
		return
	fi

	# Grab a bunch of flags, and apply them to "the current" regex
	local -a args
	while _is_flag "$1"; do
		args+=("$1")
		shift
	done

	# TODO: I'd like to keep words -c . a e i o u to count the final result, not return no results because 123,456 doesn't contain a e i o or u
	args+=("$1")

	# error checking - there should be at least one argument left, so shift should succeed
	if ! shift; then
		echo "not enough arguments after flags '${args[@]}'" >&2
		return 1
	fi

	( # TODO: `local -` instead of a subshell?
		set -o pipefail
		ack "${args[@]}" | words "$@"
	)
}

function wordle {
	about "solve the NYT's wordle puzzle (words with implicit 5-letter filter; and ..x and x.. both mean ..x.. (words with dots are padded by dots on the other side to make 5 letters. Not smart enough to fix ..[xy] ))"
	param "any: args to words command"

	# take the given $@ array, apply it one-arg-per-line, then use the outputted lines as args to words
	# Ignore words with capital letters, 's, and the several variants of xxvii
	words -I -v "[A-Z']" ^.....$ -v '^x[xvi]+$' $(for word; do printf "%s\n" "$word"; done | wordle-pad.py)
}

function spelling-bee {
	about "solve the NYT's spelling bee puzzle"
	param "1: permissible letters (will go into a regex []-grouping)"
	param "2: required letters (will go into a regex []-grouping)"
	# exclude uppercase letters and the apostrophe
	# require 4-or-more letters
	# exclude any letters not in $1
	# require a match with at least one $2 letters
	# TODO: perf  might be better if we test $2 first
	words -I -v "[A-Z']" \
		.... \
		-v "[^${1?Need a valid set of permissible letters}]" \
		"[${2?Need a valid set of required letters}]"
}
