about-plugin "Easy access to the wordlist via a words command, plus NYT puzzle solvers based on it (TODO)"

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
