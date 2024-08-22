# shellcheck shell=bash
cite about-plugin
about-plugin "AWS automatically login if there's a failure"

function aws {
	if ! command aws sso loggedin &>/dev/null; then
		echo "You're not logged in to aws sso. Automatically logging you in!"
		command aws sso login
	fi
	command aws "$@"
}
