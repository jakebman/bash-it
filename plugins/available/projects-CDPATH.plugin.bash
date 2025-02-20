# shellcheck shell=bash
about-plugin 'quickly navigate configured project paths'

# TODO: is there a way to more-naturally emulate CDPATH?
# TODO: is there a way to get an argument that *would* tab-complete to a single candidate to just... be that candidate?
: "${BASH_IT_PROJECT_PATHS:=$HOME/Projects:$HOME/src:$HOME/work}"

function pj() {
	about 'navigate quickly to your various project directories'
	group 'projects'

	local CDPATH=${BASH_IT_PROJECT_PATHS}
	cd "$@"
}

# TODO: completion for this should include files, not just dirs
function pjo() {
	about 'open a file from one of your projects in your editor'
	group 'projects'

