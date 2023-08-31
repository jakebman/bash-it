
cite about-plugin
about-plugin 'keep some facts around about what happens with curl output'


_command_exists curl || return # don't create the function if the binary is missing

function _curl-logging-helper {
	# TODO: log rotation/storage concerns
	(
		printf '# '
		shell-quote curl "$@"
		cat
	)>> ~/curlheaders.txt
}

function curl {
	# TODO: enhancement request - what if we auto-jq the result? Potentially should be in a different plugin
	command curl "$@" --dump-header >(_curl-logging-helper "$@")
}

