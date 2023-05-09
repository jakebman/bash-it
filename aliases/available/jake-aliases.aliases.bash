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

# Technically typos, these are just convenience names
alias ltre=ltree
alias ltreee=ltree

# I really like permament differences
alias watch='watch --differences=permanent'

alias cht=cht.sh

alias m=mr

# Not a 'typo' so much as a brain fart
alias maven=mvn

# git commands that... I don't care to add git to

# 'Vanilla' aliases
alias commit='git commit'
alias clone='git clone'
# pull can have special meaning in $HOME
function pull {
	if [ "$PWD" == ~ ] ; then
		mr up
	else
		git pull "$@"
	fi
}
alias push='git push'
alias rebase='git rebase'
alias merge='git merge'
# git errors if add has no args (prints advice.addEmptyPathspec)
# And this is another for the "it's functionally an alias, so sue me" pile
function add {
	if [ "$#" -eq 0 ] ; then
		git add -p "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git add "$@"
	fi
}
alias status='git status'
alias stash='git stash'
alias show='git show'
alias branch='git branch'
alias blame='git blame'
alias log='git log'
alias remote='git remote'
alias ls-files='git ls-files'
# Exceptions to 'Duplicating' aliases, below. These *could* change, but they should nominally still look like:
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
alias comit='git commit' # typo, which also has an alias

# 'Not exactly duplicating' aliases
# Not all of these are duplicating a git alias, but they're not exactly typos either
# They exist to make my CLI invocations easier, and would be more properly considered
# as useful `j` aliases, than git alises (they allow j to be invoked in a git context)
alias jdiff='git j --diff'
alias jdif='git j --diff'
alias jdf='git j --diff' # has a git alias
alias jfd='git j --diff' # typo
alias jd='git j --diff'
alias jmerge='git j --merge'
alias jmg='git j --merge' # has a git alias
alias jm='git j --merge'
alias jws='git j --ws' # has a git alias


# Safety valve (kept at end to have the final say). It's REALLY IMPORTANT to keep the -p
alias restore='git restore -p'
