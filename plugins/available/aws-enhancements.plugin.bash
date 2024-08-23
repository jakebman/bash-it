# shellcheck shell=bash
cite about-plugin
about-plugin "AWS automatically login if there's a failure, allow a custom browser setting via AWS_BROWSER"

function aws-autologin {
	about "automatically log in to aws sso if you're not"
	# NB: it's useful to create an alias in aws cli for this command. Imagine 'aws loggedin' here
	if ! command aws sts get-caller-identity &>/dev/null; then
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
	about "Respect new flag AWS_BROWSER, which is allowed to differ from your normal BROWSER env variable"
	local BROWSER="${AWS_BROWSER-$BROWSER}"
	_log_debug "using browser '$BROWSER'"
	BROWSER="${BROWSER}" aws-autologin "$@"
}

function aws {
	aws-with-browser "$@"
}
