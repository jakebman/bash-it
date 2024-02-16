
cite about-plugin
about-plugin 'Enhancements for curl - log the commands and their headers; using $PAGER, bat or less for pagination if available; [TODO] using JQ to format json output to STDOUT'
# Load after other plugins, which load at 250
# Specifically, we want to load *after* the jq plugin. We're already after the jq-implicit-less alias, which loads at 150
# (I'm not certain this is strictly necessary, though)
# BASH_IT_LOAD_PRIORITY: 251

_command_exists curl || return # don't create the function if the binary is missing

function _curl-choose-pager {
	if _command_exists bat; then
		echo bat
	else
		echo less
	fi
}

: ${BASHIT_CURL_PAGER:=${PAGER:-$(_curl-choose-pager)}}

function _curl-jqing-and-paging-helper {
	# TODO. This is currently a stub.
	# It's going to be tricky to automatically decide whether or not to pipe to jq
	# I think I need to curl to a temp file so that jq can 'sniff' the file and then decide
	# For now, we can just do paging:
	$BASHIT_CURL_PAGER
}

# allow for curl-logging plugin to apply or not
function _curl-maybe-logging {
	curl "$@"
}
if _command_exists _curl-logging; then
	function _curl-maybe-logging {
		_curl-logging "$@"
	}
fi

function curl {
	if [[ -t 1 ]]; then
		_curl-maybe-logging "$@" | _curl-jqing-and-paging-helper
	else
		_curl-maybe-logging "$@"
	fi
}
