cite about-plugin
about-plugin 'Helpers to more easily work with Docker in a WSL environment'

: "${BASH_IT_DOCKER_DESKTOP_LOCATION:=/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe}"

function docker-start {
	about "start Window's Docker Desktop, so that docker commands don't complain about //./pipe/dockerDesktopLinuxEngine"
	"${BASH_IT_DOCKER_DESKTOP_LOCATION}"
}

