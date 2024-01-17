# shellcheck shell=bash
about-alias "Jake's custom commands that are aliases"

alias tulpn='netstat -tulpn'

# They're functionally aliases; so sue me
# (They also have typo aliases)
function lls {
	ll --color "$@" | less
}
# WARNING!!!! CONCERNING OVER-RELIANCE ON BASH MINUTAE:
# The alias ll='ls -alF' already exists. We used it above.
# We're overwriting it here, using a function that... uses *it*.
# This is FINE by the rules of bash! The prior alias was *expanded* during
# the creation of the function, so there's no circular reference
alias ll=lls

# This overrides one from general
unalias h
function h {
	history "$@" | less
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

# Sometimes I use this name for the command rather than its normal name. Oops.
alias maven=mvn


# ll, plus other flags
alias lla='ll -a'
alias llh='ll -h'

# The rest of the file is entirely git commands that... I don't care to add git to

# 'Magic' aliases - smarter than their corresponding git command (they can see more Jake context)

# pull can have special meaning in $HOME
function pull {
	if [ "$#" -ne 0 ] ; then
		# If we have arguments, it's because I'm thinking this is a git pull
		git pull "$@"
	elif [ "$PWD" == ~ ] || [ -f .mrconfig ] ; then
		# yes, there's a .mrconfig in ~, but there's no disk access to check $PWD first
		mr up "$@"
	else
		# Technically, we know there are no args to pass to pull here, but it keeps parallel structure
		# And we should fallback to git fetch in case we're in a situation where the remote branch is deleted (merged)
		# or never existed (local draft branch). I don't expect fetch to take the same arguments as pull even if
		# they're both empty
		git pull "$@" || git fetch
	fi
}
alias gpull='git pull' # sometimes I want to pull in ~

function status {
	# see pull, above
	if [ "$PWD" == ~ ] || [ -f .mrconfig ] ; then
		mr status "$@"
	else
		git status "$@"
	fi
}
alias gstatus='git status' # Sometimes, I want to run status in ~

function status-or-show {
	if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --quiet && JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --quiet ; then
		# status is basically bunk
		git show "$@"
	else
		git status "$@"
	fi
}
alias s=status-or-show

function _jake-banner-display {
	about "display a banner, but don't care if it fails"
	figlet -t -f mini "$@" "$JAKE_BANNER_WHY" 2>/dev/null || true
}

# git errors if add has no args (prints advice.addEmptyPathspec)
# And this is another for the "it's functionally an alias, so sue me" pile
function add {
	if [ "$#" -eq 0 ] ; then
		_jake-banner-display "GIT ADD"
		# TODO: if there is *exactly* one trivial change, automatically add it and print the diff
		# (Not sure what 'trivial' means yet, but it could be counting lines, or diff sections, or changed files)
		# For instance, diff sections might not be super smart - I've wanted to split 'a single' diff section when adding before
		git add -p "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git add "$@"
	fi
}

# commit with one argument is either add/commit the file, or commit with the given message
function commit {
	# stash some flags that can be "transparent" to this feature
	# (these can only be BEFORE the message for now... potentially always)
	local -a args
	case "$1" in
		-a|--all|--amend )
			args+=("$1")
			shift
			;;
	esac

	# Internal banner note
	local JAKE_BANNER_WHY="... TO COMMIT"

	# exactly one argument, and it's not a flag. (don't eat --message=typo, for instance)
	if [ "$#" -eq 1 ] && ! [[ "$1" == -* ]] ; then
		if [ -f "$1" ] ; then
			# is a file. add, then interactive commit
			JAKE_SUPPRESS_GIT_SQUAWK=1 add "$1"
			git commit
		else
			# is a commit message. Commit with that message

			if [ -v args ] ; then
				: # TODO: this only really checks if I added *something* to args; not specifically '-a'
			elif JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --quiet ; then
				# No staged changes. Commit will fail. User probably wants to select some changes to add
				JAKE_SUPPRESS_GIT_SQUAWK=1 add # dunno which file you wanted, but go ahead and do an interactive add
				# STILL no changes. Commit will obviously fail. User probably a little confused
				if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --quiet ; then
					echo
					echo "no changes for commit message '$1'. No commit created. Thank you."
					echo
					git diff --staged --quiet # get the git squawk, but only if the outer test failed
					# TODO: no squawk occurs if Ctrl+C kills us
					return 1
				fi
			fi

			git commit "${args[@]}" -m "$1"
		fi
	else
		git commit "${args[@]}" "$@"
	fi
}
alias amend='commit --amend'

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

function remote {
	if [ "$#" -eq 0 ] || [[ "$1" == 'show' ]]; then
		git remote -v "$@"
	else
		git remote "$@"
	fi
}

function reset {
	if echo "$@" | grep -q HEAD ; then
		echo "You probably meant git reset. Don't just do this willy-nilly!" >&2
	fi
	command reset "$@"
	if echo "$@" | grep -q HEAD ; then
		echo "You probably meant git reset. Don't just do this willy-nilly!" >&2
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
alias shortlog='git shortlog'
alias ls-files='git ls-files'
alias submodule='git submodule'
alias cherry-pick='git cherry-pick'
alias tag='git tag'
alias reflog='git reflog'
alias rev-parse='git rev-parse'
alias untracked='git untracked' # a git alias, probably 'status --untracked'
# git-extras
alias authors='git authors'
alias lock='git lock'
alias locked='git locked'
alias unlock='git unlock'
# Exceptions to 'Duplicating' aliases, below. The git alias's behavior *could* change, and I want the
# bare command's behavior to continue to track as-if it were just adding git to it. I do expect their
# behavior to remain how it's described here, though.
alias rainbow='git rainbow' # colored graphlines in the terminal
alias logp='git logp' # log with patch
alias logs='git logs' # log with stats (+++-- indicators)
alias logn='git logn' # log with numstats
alias tags='git tags' # list the tags

# 'Duplicating' aliases
# These could have been written as `alias X='git X'`, because they're
# all bash aliases for git aliases I've written.
# But! because I don't ever expect to change what the underlying git alias does,
# I'd rather skip the indirection and just specify the correct behavior in the alias
alias co='git checkout'
alias ignored='git status --ignored'
alias staged='git diff --staged'
alias addp='git add --patch'
alias autostash='git pull --rebase --autostash' # I ususally mean rebase as well as autostash

# shorthand command
alias s=status-or-show

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
