about-plugin "Easy access to the wordlist via a words command, plus NYT puzzle solvers based on it"

function words {
	about 'print the word list, paged. Arguments are ack filters on a word list (flags apply to the next non-flag argument, which is assumed to be a regex). If stdin is not a terminal, it is used in lieu of the ${WORDLIST:/usr/share/dict/words}'
	# Implementation note: this is *incredibly recursive*

	if [[ -t 0 ]]; then
		cat "${WORDLIST:-/usr/share/dict/words}" | words "$@"
		return # Not strictly necessary if EVERYTHING is if/elif/else. But that can't be guaranteed locally
	elif [[ "$#" -eq 0 ]]; then
		less
		return # see above
	else
		# Grab a bunch of flags, and apply them to "the current" regex
		local -a args
		while _is_flag "$1"; do
			args+=("$1")
			shift
		done

		args+=("$1")

		# error checking - there should be at least one argument left, so shift should succeed
		if ! shift; then
			echo "not enough arguments after flags '${args[@]}'" >&2
			return 1
		fi

		ack "${args[@]}" | words "$@"
		return # see above
	fi

	# PUTTING CODE HERE MIGHT BE A VERY BAD IDEA. SEE ABOVE
}

function wordle {
	about "solve the NYT's wordle puzzle (words with implicit 5-letter filter)"
	param "any: args to words command"

	words -I -v "[A-Z']" \
		^.....$ \
		"$@"
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