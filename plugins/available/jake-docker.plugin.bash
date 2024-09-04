cite about-plugin
about-plugin 'Helpers to more easily work with Docker'


function docker-run {
	about 'transiently run a docker image (essentially -it, --rm)'
	group 'docker'
	docker run -it --rm "$@"
}


: ${BASH_IT_DOCKER_ADHOC_TAG:=adhoc-run-target}
function docker-build-and-run {
	about "build the current docker, and immediately run it with -it and --rm"
	group 'docker'
	local -a args
	local arg haveBuildDir
	for arg; do
		# Over-broad. It'll grab --output-dir some-dir/
		if [ -d "$arg" ]; then
			haveBuildDir=true
		fi
	done
	if [ true != "$haveBuildDir" ]; then
		args+=(.)
	fi

	docker build --tag "${BASH_IT_DOCKER_ADHOC_TAG}" "$@" "${args[@]}" && docker-run "${BASH_IT_DOCKER_ADHOC_TAG}"
}
