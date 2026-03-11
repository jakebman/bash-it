# shellcheck shell=bash
about-plugin 'quickly navigate configured project paths'

# TODO: is there a way to more-naturally emulate CDPATH?
# TODO: is there a way to get an argument that *would* tab-complete to a single candidate to just... be that candidate?
: "${BASH_IT_PROJECT_PATHS:=$HOME/Projects:$HOME/src:$HOME/work}"

function pj() {
	about 'navigate quickly to your various project directories'
	group 'projects'

	if [ "$#" -eq 0 ]; then
		>&2 echo "No project specified. pj is not a mind reader"
		return 1
	fi


	# Aliases are secondary, typo-like solutions. If you have projects foo-a and foo-b, you can create
	# a symlink in one of the BASH_IT_PROJECT_ALIASES directories from foo- to foo-a so a quick jump
	# will always reach foo-a instead of failing to find a project named foo-
	# This feature leverages the `-P` behavior of `cd`, below
	local CDPATH="${BASH_IT_PROJECT_PATHS}${BASH_IT_PROJECT_ALIASES+:}${BASH_IT_PROJECT_ALIASES}"

	# TODO: the POSIX spec on cd specifically says "Use $PWD if cd can't find any other matches"
	# This is not ideal, as I want to specifically exclude it from consideration
	# I might have to re-implement cd, skipping step 7? https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cd.html
	# Pass -P to follow symlinks to their destination
	cd -P "$@"
}

# TODO: completion for this should include files, not just dirs
function pjo() {
	about 'open a file from one of your projects in your editor'
	group 'projects'
	# TODO
}
