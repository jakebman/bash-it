cite about-plugin
about-plugin 'Helpers to more easily work with Docker'

function docker-run {
	about 'transiently run a docker image (essentially -it, --rm)'
	group 'docker'
	if ((0 == $#)); then
		docker run -it --rm "${BASH_IT_DOCKER_ADHOC_TAG}"
	else
		docker run -it --rm "$@"
	fi
}

: ${BASH_IT_DOCKER_ADHOC_TAG:=adhoc-run-target}
function docker-build-and-run {
	about "build the current docker, and immediately run it with -it and --rm"
	group 'docker'
	local -a args
	local arg haveBuildDir
	case $# in
		1)
			if [ -d "$1" ]; then
				haveBuildDir=true
			elif [ -f "$1" ]; then
				args+=(-f "$1")
				shift
			fi
			;;
		*)
			for arg; do
				# Over-broad. It'll grab --output-dir some-dir/
				if [ -d "$arg" ]; then
					haveBuildDir=true
				fi
			done
			;;
	esac

	if [ true != "$haveBuildDir" ]; then
		args+=(.)
	fi
	docker build --tag "${BASH_IT_DOCKER_ADHOC_TAG}" "$@" "${args[@]}" && docker-run "${BASH_IT_DOCKER_ADHOC_TAG}"
}
