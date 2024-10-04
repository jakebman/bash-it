cite about-plugin
about-plugin 'keep some facts around about what happens with curl output'

_command_exists curl || return # don't create the function if the binary is missing

function _curl-logging-helper {
	# TODO: log rotation/storage concerns. Potentially using mktemp?
	(
		# NB: I prefer %q over shell-quote for shell quoting. This note lives here to remind myself
		# TODO: I'm honestly a little curious the difference between `shell-quote` and printf "%q" ...
		# See https://askubuntu.com/a/354929
		printf '#'
		printf ' %q' curl "$@" # rely on printf's "re-used as necessary" behavior
		printf '\n'
		cat
	) >> ~/curlheaders.txt
}

function _curl-logging {
	command curl --dump-header >(_curl-logging-helper "$@") "$@"
}

function curl {
	_curl-logging "$@"
}
