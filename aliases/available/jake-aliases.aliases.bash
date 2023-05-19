# shellcheck shell=bash
about-alias "Jake's custom commands that are aliases"

alias tulpn='netstat -tulpn'

# They're functionally aliases; so sue me
# (They also have typo aliases)
function lls {
	ll --color "$@" | less
}

function ltree {
	# I already set CLICOLOR_FORCE, so -C is not required, but it's more consistent to set it here
	# minor rant: why doesn't tree have a long option for this?
	# invoke tree via `command`, even though it's unambiguous at this time, because
	# if we move `alias tree=ltree` above this line, we end up in infinite recursion
	command tree -C "$@" | less
}

# I really like permament differences
alias watch='watch --differences=permanent'

alias cht=cht.sh

# Sometimes I use this name for the command rather than its normal name. Oops.
alias maven=mvn

# The rest of the file is entirely git commands that... I don't care to add git to

# 'Magic' aliases - smarter than their corresponding git command (they can see more Jake context)

# pull can have special meaning in $HOME
function pull {
	# yes, there's a .mrconfig in ~, but there's no disk access to check $PWD first
	# (and the $PWD check was here first - the .mrconfig check shouldn't feel bolted-on, but it does)
	if [ "$PWD" == ~ ] || [ -f .mrconfig ] ; then
		mr up "$@"
	else
		git pull "$@"
	fi
}

function status {
	# see pull, above
	if [ "$PWD" == ~ ] || [ -f .mrconfig ] ; then
		mr status "$@"
	else
		git status "$@"
	fi
}

function _jake-banner-display {
	about "display a banner, but don't care if it fails"
	figlet -t -f mini "$@" 2>/dev/null || true
}

# git errors if add has no args (prints advice.addEmptyPathspec)
# And this is another for the "it's functionally an alias, so sue me" pile
function add {
	if [ "$#" -eq 0 ] ; then
		_jake-banner-display "GIT ADD"
		git add -p "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git add "$@"
	fi
}

# commit with one argument is either add/commit the file, or commit with the given message
function commit {
	# stash some flags (just -a for now) before determining if there is 'only' one argument
	local -a args
	if [[ "$1" == "-a" ]] ; then
		args+=($1)
		shift
	fi

	# exactly one argument, and it's not a flag. (don't eat --message=typo, for instance)
	if [ "$#" -eq 1 ] && ! [[ "$1" == -* ]] ; then
		if [ -f "$1" ] ; then
			# is a file. add, then interactive commit
			add "$1"
			git commit
		else
			# is a commit message. Commit with that message
			git commit "${args[@]}" -m "$1"
		fi
	else
		git commit "${args[@]}" "$@"
	fi
}

# Print a header warning that this is NOT ADD, and DESTUCTIVE
function restore {
	echo -ne "$echo_red"
	_jake-banner-display "!!! GIT RESTORE !!!"
	sleep .2
	_jake-banner-display "!!!!! TAKE CARE !!!!!"
	echo -ne "$echo_reset_color"

	sleep .3
	git restore -p "$@"
}

function unstage {
	if [ "$#" -eq 0 ] ; then
		_jake-banner-display "GIT RESTORE --STAGED"
		git unstage -p "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git unstage "$@"
	fi
}


# 'Vanilla' aliases - these commands simply add 'git' at the beginning
alias clone='git clone'
alias push='git push'
alias fetch='git fetch'
alias rebase='git rebase'
alias merge='git merge'
alias stash='git stash'
alias show='git show'
alias branch='git branch'
alias blame='git blame'
alias log='git log'
alias remote='git remote'
alias ls-files='git ls-files'
alias authors='git authors'
# Exceptions to 'Duplicating' aliases, below. The git alias's behavior *could* change, and I want the
# bare command's behavior to continue to track as-if it were just adding git to it. I do expect their
# behavior to remain how it's described here, though.
alias rainbow='git rainbow' # colored graphlines in the terminal
alias logp='git logp' # log with patch
alias logs='git logs' # log with stats (+++-- indicators)
alias logn='git logn' # log with numstats

# 'Duplicating' aliases
# These could have been written as `alias X='git X'`, because they're
# all bash aliases for git aliases I've written.
# But! because I don't ever expect to change what the underlying git alias does,
# I'd rather skip the indirection and just specify the correct behavior in the alias
alias co='git checkout'
alias ignored='git status --ignored'
alias staged='git diff --staged'
alias addp='git add --patch'

# 'Not exactly duplicating' aliases
# Not all of these are duplicating a git alias, but they're not exactly typos either
# They exist to make my CLI invocations easier, and would be more properly considered
# as useful `j` aliases, than git alises (they allow j to be invoked in a git context)
alias jstg='git j --staged'
alias jst='git j --staged'
alias jsg='git j --staged'
alias jdiff='git j --diff'
alias jdif='git j --diff'
alias jdf='git j --diff' # has a git alias
alias jd='git j --diff'
alias jmerge='git j --merge'
alias jmg='git j --merge' # has a git alias
alias jm='git j --merge'
alias jws='git j --ws' # has a git alias
