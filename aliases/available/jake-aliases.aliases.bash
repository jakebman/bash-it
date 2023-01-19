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
alias co='git checkout' # I have a git alias for `co`, but the bash alias shouldn't depend on that
alias ignored='git status --ignored' # I also have a git alias for `ignored`
alias commit='git commit'
alias comit='git commit' # typo
alias pull='git pull'
alias push='git push'
alias rebase='git rebase'
alias merge='git merge'
alias add='git add'
alias status='git status'
alias branch='git branch'
alias log='git log'
alias remote='git remote'
alias staged='git diff --staged'
alias restore='echo "Running git restore without thinking is a way to hurt yourself"'
