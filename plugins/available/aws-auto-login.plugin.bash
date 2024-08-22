# shellcheck shell=bash
cite about-plugin
about-plugin "AWS automatically login if there's a failure"

function aws {
	about "automatically log in to aws sso if you're not"
	# NB: it's useful to create an alias in aws cli for this command. Imagine 'aws loggedin' here
	if ! command aws sts get-caller-identity &>/dev/null; then
		echo "You're not logged in to aws sso. Automatically logging you in!"
		command aws sso login || return
	fi
	command aws "$@"
}
