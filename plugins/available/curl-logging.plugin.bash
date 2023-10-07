
cite about-plugin
about-plugin 'keep some facts around about what happens with curl output'


_command_exists curl || return # don't create the function if the binary is missing

function _curl-logging-helper {
	# TODO: log rotation/storage concerns
	(
		# NB: I prefer %q over shell-quote for shell quoting. This note lives here to remind myself
		# TODO: I'm honestly a little curious the difference between `shell-quote` and printf "%q" ...
		# See https://askubuntu.com/a/354929
		printf '# %q %q\n' curl "$@"
		cat
	)>> ~/curlheaders.txt
}

function curl {
	# TODO: enhancement request - what if we auto-jq the result? Potentially should be in a different plugin
	command curl "$@" --dump-header >(_curl-logging-helper "$@")
}

