# shellcheck shell=bash
about-plugin "cd-git: a function that goes to your git repo's root"

function cd-git {
	cd "$(git root)"
}
