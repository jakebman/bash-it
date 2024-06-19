# shellcheck shell=bash
cite about-plugin
about-plugin 'perform some google-y searches from the cli with the google and gmail command'

function google() {
	about 'perform a google search'
	param '*: a series of words that are concatenated into the google query. TODO: you currently need to urlencode ampersands yourself. Sorry :('
	# TODO: urlencode ampersands in the query
	# TODO: but maybe parameters that start with & and have an = (ex: `&lang=en`) are unmolested. Prepend a space (like `google " &lang=en"`) to prevent this.
	# TODO: and perhaps this only applies to final params, so `google "&lang=en" ""` also disables this. Essentially "query parameters are accepted only at the end"
	browse "https://google.com/search?q=$*"
	# TODO: &ie=<input encoding> might be a useful query parameter to include
}

function gmail {
	about "open gmail in your browser, including search terms, if present"
	if [[ "$#" -eq 0 ]]; then
		browse "http://gmail.com/"
	else
		# NB: $* over $@, because that keeps all the string as one string argument, w/o breaking it out
		browse "https://mail.google.com/mail/u/0/#search/$*"
	fi
}
