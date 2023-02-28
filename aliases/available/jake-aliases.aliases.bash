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
	tree -C "$@" | less
}

# Technically typos, these are just convenience names
alias ltre=ltree
alias ltreee=ltree

function jqless {
	jq --color-output "$@" | less
}

# I really like permament differences
alias watch='watch --differences permanent'

# git commands that... I don't care to add git to

# 'Vanilla' aliases
alias commit='git commit'
alias pull='git pull'
alias push='git push'
alias rebase='git rebase'
alias merge='git merge'
alias add='git add'
alias status='git status'
alias show='git show'
alias branch='git branch'
alias log='git log'
alias remote='git remote'
alias ls-files='git ls-files'

# 'Alias' aliases
# These could all be `alias X='git X'` because X is a git alias, but they're not.
# Because I don't ever expect to change what the underlying git alias does,
# I'd rather skip the indirection and just specify the correct behavior in the alias
alias co='git checkout'
alias ignored='git status --ignored'
alias staged='git diff --staged'
alias comit='git commit' # typo, which also has an alias

# Safety valve (kept at end to have the final say):
alias restore='echo "Running git restore without thinking is a way to hurt yourself"'
