cite about-plugin
about-plugin 'Helpers to more easily work with Docker in a WSL environment'

: "${BASH_IT_DOCKER_DESKTOP_LOCATION:=/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe}"

_BASH_IT_DOCKER_AUTOSTART_EXCEPTIONS+=(version)
# It's worth adding your own exceptions
# _BASH_IT_DOCKER_AUTOSTART_EXCEPTIONS+=(login loggedin logout)

function _docker-autostart-exception {
	about "given a docker cli command, should the docker-autostart behavior ignore it?"
	# https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
	local exception
	for exception in "${_BASH_IT_DOCKER_AUTOSTART_EXCEPTIONS[@]}"; do
		if [ "$exception" = "$1" ]; then
			return
		fi
	done
	return 1
}

function docker-autostart {
	about "automatically start WSL's docker before running docker commands"
	if _docker-autostart-exception "$@"; then
		_log_debug "Not automatically starting docker to run '$@' - it is an exception"
	elif ! docker-is-running; then
		echo "Docker is not currently running. Starting it now."
		docker-start || return
		echo
		echo "============= Now proceeding with your original '$1' command =================="
		echo "==>" docker "$@"
		echo "============= Now proceeding with your original '$1' command =================="
	fi
	docker "$@"
}

function docker-start {
	about "start Window's Docker Desktop, so that docker commands don't complain about not having integration installed, or about a missing //./pipe/dockerDesktopLinuxEngine"
	"${BASH_IT_DOCKER_DESKTOP_LOCATION}" && echo "Docker desktop kicked off. Expect the UI in a few seconds"
}

function docker-is-running {
	about "succeeds if docker is running, fails otherwise"
	# This is the mechanism by which the '/mnt/c/Program Files/Docker/Docker/resources/bin/docker' file
	# checks to see if the WSL2 integration is present in the current machine.
	[ -f /usr/bin/docker ]
}
