cite about-plugin
about-plugin 'Helpers to more easily work with Docker'

: ${BASH_IT_DOCKER_ADHOC_TAG:=adhocRunTarget}
function docker-build-and-run {
	about "build the current docker, and immediately run it with -it and --rm"
	group 'docker'
	docker build --tag "${BASH_IT_DOCKER_ADHOC_TAG}" "$@" && docker run --rm -it "${BASH_IT_DOCKER_ADHOC_TAG}"
}
