# shellcheck shell=bash
cite about-plugin
about-plugin "AWS automatically login if there's a failure, allow a custom browser setting via AWS_BROWSER"

_BASH_IT_AWS_AUTOLOGIN_EXCEPTIONS=(sso sts)
# It's worth adding your own exceptions for login/logout aws-cli aliases that you create
# _BASH_IT_AWS_AUTOLOGIN_EXCEPTIONS+=(login loggedin logout)

function _aws-autologin-exception {
	about "given an aws cli command, should the aws-autologin behavior ignore it?"
	# https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
	local exception;
	for exception in "${_BASH_IT_AWS_AUTOLOGIN_EXCEPTIONS[@]}"; do
		if [ "$exception" = "$1" ]; then
			return
		fi
	done
	return 1
}

function aws-autologin {
	about "automatically log in to aws sso if you're not"
	if _aws-autologin-exception "$@"; then
		_log_debug "not automatically logging into aws to run '$@' - it is an exception"
	elif ! command aws sts get-caller-identity &>/dev/null; then
		# NB: it's useful to create an alias in aws cli for this sts command. Imagine 'aws loggedin' here
		echo "You're not logged in to aws sso. Automatically logging you in!"
		command aws sso login || return
		echo
		echo "============= Now proceeding with your original '$1' command =================="
		echo "==>" aws "$@"
		echo "============= Now proceeding with your original '$1' command =================="
	fi
	command aws "$@"
}

function aws-with-browser {
	about "Respect new flag BASH_IT_AWS_BROWSER and/or AWS_BROWSER, which is allowed to differ from your normal BROWSER env variable"
	local BROWSER="${BASH_IT_AWS_BROWSER-${AWS_BROWSER-$BROWSER}}"
	_log_debug "using browser '$BROWSER'"
	BROWSER="${BROWSER}" aws-autologin "$@"
}

function aws-with-paging {
	about "attempt to apply paging to aws output. Especially, try to get jq *colored* output paged, if possible"
	echo TODO
}

function aws {
	aws-with-browser "$@"
}
