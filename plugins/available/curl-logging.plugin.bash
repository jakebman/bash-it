
cite about-plugin
about-plugin 'keep some facts around about what happens with curl output'


_command_exists curl || return # don't create the function if the binary is missing

function _curl-logging-helper {
	# TODO: log rotation/storage concerns
	echo "# curl $@" >> ~/curlheaders.txt
	cat >> ~/curlheaders.txt
}

function curl {
	command curl --dump-header >(_curl-logging-helper "$@") "$@"
}

