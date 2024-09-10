# shellcheck shell=bash
about-alias "Jake's custom commands that are aliases"

alias tulpn='netstat -tulpn'

# They're functionally aliases; so sue me
# (They also have typo aliases)
function lls {
	ll --color "$@" | pager
}
# WARNING!!!! CONCERNING OVER-RELIANCE ON BASH MINUTAE:
# The alias ll='ls -alF' already exists. We used it above.
# We're overwriting it here, using a function that... uses *it*.
# This is FINE by the rules of bash! The prior alias was *expanded* during
# the creation of the function, so there's no circular reference
alias ll=lls
# Override bash-it's --all with --Almost-All
alias l='ls -AF'

# I really like permament differences
alias watch='watch --differences=permanent'

# Sometimes I use this name for the command rather than its normal name. Oops.
alias maven=mvn

# ll, plus other flags
alias lla='ll -a' # NB: -a is implied in ll. This is apparently a no-op. Oops?
alias llh='ll -h'
alias llt='ll -t'
alias llht='ll -ht'
alias llth='ll -ht' # would be a typo, but I don't actually know which should be canonical

# The rest of the file is entirely git commands that... I don't care to add git to

# 'Magic' aliases - smarter than their corresponding git command (they can see more Jake context)
# TODO: these are potentially 'implicit' commands a la jake-implicit-commands

# pull can have special meaning in $HOME, or other places with mr configs
function pull {
	if [ "$#" -ne 0 ]; then
		# If we have arguments, it's because I'm thinking this is a git pull
		git pull "$@"
	elif [ ~ = "$PWD" ] || [ -f .mrconfig ]; then
		# Get local coloring from git pull, even through mr up
		local GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
		GIT_CONFIG_COUNT=1
		GIT_CONFIG_KEY_0=color.ui
		GIT_CONFIG_VALUE_0=always
		export GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0

		# yes, there's a .mrconfig in ~, but there's no disk access to check $PWD first
		mr up "$@" |& awk --assign boredRatio="${JAKE_STATUS_BORED_RATIO:-42}"  '
			function print_and_empty_info() {
				if (! repo) return
				print repo
				print info
				info = ""
				fflush()

				# reset the boredom counter
				emptyLine = 0
			}

			# starts a repo report
			/^mr update:/ {
				# TODO: track repos which do not print
				if (info) print_and_empty_info()
				repo = $0
			}

			# lines in a repo report. Beautifully, info remains empty/false if concatenates an empty line
			# so any number of prefixed empty lines are all eaten into the empty string
			# SUBTLE: the trailing empty string DOES get glommed in here, and is a natural separator between sections
			!/^mr update:/ && !/^Already up to date.$/ &&
				!/^Junk Drawer: Skipping junk drawer project.$/ && !/^Fetching / {
				if (info) {
					info = info "\n"
				}
				info = info $0
			}
			/Fetching / {
				$1 = ""
				repo = repo "," $0;
			}

			/^$/ {
				# with a hundred tracked repos, I want some intermediate output
				emptyLine+=1
				if(!(emptyLine % boredRatio)) {
					repo=repo " (progress marker for " emptyLine "th quiet entry)"
					print_and_empty_info()
				}
			}

			# When we are done, we print the last repo, even if it had empty info
			# this also serendipituously covers the final summary "mr status: finished (86 ok)"
			END {
				print_and_empty_info()
			}
		'
	else
		# Technically, we know there are no args to pass to pull here, but it keeps parallel structure
		# And we should fallback to git fetch in case we're in a situation where the remote branch is deleted (merged)
		# or never existed (local draft branch). I don't expect fetch to take the same arguments as pull even if
		# they're both empty
		git pull "$@" || git fetch
	fi
}

function status {
	# see pull, above
	local status=0
	if [ ~ = "$PWD" ] || [ -f .mrconfig ]; then
		mr status "$@" | awk --assign boredRatio="${JAKE_STATUS_BORED_RATIO:-42}"  '
			function print_and_empty_info() {
				if (! repo) return
				print "#" repo
				print info
				info = ""
				fflush()

				# reset the boredom counter
				emptyLine = 0
			}

			# starts a repo report
			/^mr status:/ {
				# TODO: track repos which do not print
				if (info) print_and_empty_info()
				repo = $0
			}

			# lines in a repo report. Beautifully, info remains empty/false if concatenates an empty line
			# so any number of prefixed empty lines are all eaten into the empty string
			# SUBTLE: the trailing empty string DOES get glommed in here, and is a natural separator between sections
			!/^mr status:/ {
				if (info) {
					info = info "\n"
				}
				info = info $0
			}

			/^$/ {
				# with a hundred tracked repos, I want some intermediate output
				emptyLine+=1
				if(!(emptyLine % boredRatio)) {
					repo=repo " (progress marker for " emptyLine "th quiet entry)"
					print_and_empty_info()
				}
			}

			# When we are done, we print the last repo, even if it had empty info
			# this also serendipituously covers the final summary "mr status: finished (86 ok)"
			END {
				print_and_empty_info()
			}
		' | bat --style=plain --paging=never --language "Git Attributes" # good enough
		# TODO: did I harm this exit code with the awk processing?
		status="$?"

		echo "git repo status:"
	fi

	# I want an unconditional git status. We *can* also include mr, above, but this *must* happen anyway
	# (but if mr status fails, it would be nice to propagate that failure here, too)
	git status "$@" && return $status
}

function realpath-and-rainbow {
	about "preceed a rainbow with a realpath, if relevant"
	realpath 2> /dev/null # specifically want the zero-arg "go to the real path" behavior

	if [[ "$#" -eq 0 ]]; then
		git rainbow-all "$@"
	else
		git rainbow "$@"
	fi
}

function _jake-banner-display {
	about "display a banner, but don't care if it fails"
	figlet -t -f mini "$@" "$JAKE_BANNER_WHY" 2> /dev/null || true
}

# git errors if add has no args (prints advice.addEmptyPathspec)
# And this is another for the "it's functionally an alias, so sue me" pile
function add {
	if [ "$#" -eq 0 ]; then
		# TODO: if there is *exactly* one trivial change, automatically add it and print the diff
		# (Not sure what 'trivial' means yet, but it could be counting lines, or diff sections, or changed files)
		# For instance, diff sections might not be super smart - I've wanted to split 'a single' diff section when adding before
		addp "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git add "$@"
	fi
}

function addp {
	about "reset tabstops in git add to something similar to git's core.pager= less --tabs=3,5, but with 4 spaces instead"
	# TODO: would this make sense to try under termcap's ti/te state? Would that be helpful, or weird because the output is lost?
	# https://askubuntu.com/questions/984209/how-does-less-switch-to-the-text-then-back-to-the-prompt
	# (DO NOT do this for restore - I want the patches stored in the terminal scrollback buffer)
	# put the margin in by one character (+m1), and use 'COBOL compact format extended' (-c3)
	tabs +m1 -c3
	clear -x

	_jake-banner-display "GIT ADD"
	add --patch "$@"

	local out="$?"
	tabs +m0
	return "$out"
}

function _is_flag {
	about "Succeeds if all arguments are flags (have a first character of '-'). Fails otherwise"
	local arg
	for arg in "$@"; do
		# note that shellcheck is wrong here. If arg is "-a", then x is ABSOLUTELY necessary
		# shellcheck disable=SC2268
		[[ "x${arg}" == x-* ]] || return 1
	done
	return 0
}

function cherry-pick {
	about "git cherry-pick, but if it's not a --continue/--abort/etc., try to include the (cherry picked from ...)"
	if [ "$#" -eq 1 ] && _is_flag "$1"; then # likely a --continue/etc.
		git cherry-pick "$@"
	else
		git cherry-pick -x "$@"
	fi
}

# commit with one argument is either add/commit the file, or commit with the given message
# TODO: in a situation where no flags are specified, -m is "$*", and we automatically addp any files mentioned
# TODO: this improperly rejects the situation where we only have staged renames
function commit {
	# stash some flags that can be "transparent" to this feature
	# (these can only be BEFORE the message for now... potentially always)
	local -a args
	case "$1" in
		-a | --all | --amend)
			args+=("$1")
			shift
			;;
	esac

	# Internal banner note
	local JAKE_BANNER_WHY="... TO COMMIT"

	# exactly one argument, and it's not a flag. (don't eat --message=typo, for instance)
	# TODO: if no args are flags, then the commit message is "$*", and any args-that-are-also-files are add-p'd
	# TODO: if there are no arguments at all, I want something like "here's the changes.. what's your message? what's to commit? are you sure you wanted that message?"
	if [ "$#" -eq 1 ] && ! _is_flag "$1"; then
		if [ -f "$1" ]; then
			# is a file. add, then interactive commit
			JAKE_SUPPRESS_GIT_SQUAWK=1 add "$1"
			git commit
		else
			# is a commit message. Commit with that message

			if [ -v args ]; then
				: # TODO: this only really checks if I added *something* to args; not specifically '-a'
			elif JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --quiet; then
				# No staged changes. Commit will fail. User probably wants to select some changes to add
				JAKE_SUPPRESS_GIT_SQUAWK=1 add # dunno which file you wanted, but go ahead and do an interactive add
				# STILL no changes. Commit will obviously fail. User probably a little confused
				if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --quiet; then
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
	# tab-sizing tech from addp
	tabs +m1 -c3
	clear -x

	echo -ne "${echo_red-}"
	_jake-banner-display "!!! GIT RESTORE !!!"
	sleep .2
	_jake-banner-display "!!!!! TAKE CARE !!!!!"
	echo -ne "${echo_reset_color-}"

	sleep .3
	git restore -p "$@"

	local out="$?"
	tabs +m0
	return "$out"
}

function unstage {
	if [ "$#" -eq 0 ]; then
		_jake-banner-display "GIT RESTORE --STAGED"
		git unstage -p "$@" # $@ is empty, but this is more consistent with the other branch
	else
		git unstage "$@"
	fi
}

function reset {
	# TODO: are there some resets I can do safely?
	# ex: add tags and stashes around this behavior, and allow only certain subsets:
	# if _no_git_changes && $1 == origin:  we reset the current branch to upstream, in a --hard way?
	#		Potentially, this could be function reset-to-origin
	# if _no_git_changes && $1 is ancestor of HEAD: soft reset
	if echo "$@" | grep -q HEAD; then
		echo "You probably meant git reset. Don't just do this willy-nilly!" >&2
	fi
	command reset "$@"
	if echo "$@" | grep -q HEAD; then
		echo "You probably meant git reset. Don't just do this willy-nilly!" >&2
	fi
}

function clone {
	local git_command=clone
	local retcode
	if [[ "x${PWD}" =~ /junk-drawer$ ]]; then
		# special case: shallow clone in junk-drawer
		git_command=shallow
		echo "We're in the junk drawer - using a shallow clone"
	fi
	git $git_command "$@"
	retcode="$?"
	if [[ -f .mrconfig ]]; then
		# https://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/
		local dir
		for dir; do :; done

		# basename, stripping a suffix
		dir="$(basename -s .git "$dir")"

		if [[ -d "$dir" ]]; then
			mr register "$dir"
		else
			echo "pleas manaully register $* with mr"
		fi
	fi

	return "$retcode"
}

# non-standard plan - use the prefix git to disambiguate the desired `git help` from
# the full automatic invocation of an existing command. Mostly, this lets me pick
# `git pull` over `mr up` where `pull` would otherwise pick the second one
# nb: the more-useful 'ghelp/gpull/etc.' are typos of these
alias githelp='git help' # help is actually a bash builtin
alias gitman='git man'   # git-man is amusingly also an alias to git-help
alias gitpull='git pull'
alias gitup='git up' # git aliases up to pull, but parallel structure wins, so I'm not expanding it here.
alias gitstatus='git status'

# 'Vanilla' aliases - these are aliases to existing git-<command>s (not git-<alias>es)
# These aliases simply allow for an implicit git on commands that predate any of my git-config alias additions
alias push='git push'
alias fetch='git fetch'
alias rebase='git rebase'
alias merge='git merge'
alias stash='git stash'
alias branch='git branch'
alias blame='git blame'
alias log='git log'
alias shortlog='git shortlog'
alias submodule='git submodule'
alias tag='git tag'
alias reflog='git reflog'
alias rev-parse='git rev-parse'
alias worktree='git worktree'
# git-extras
alias lock='git lock'
alias locked='git locked'
alias unlock='git unlock'

# 'Non-Duplicating' aliases - these are aliases to existing git-<alias>s, that simply allow for an implicit git
# They're only different from 'Vanilla' aliases above because we "know" that these git commands are actually git aliases
# Specifically, these are intentional exceptions to the 'Duplicating' aliases, below, which try to shortcut a level of indirection.
# These git aliases *could* become full git-X-dispatched commands in the future, and I'd love to not accidentally overwrite that
# behavior with what this file's no-longer-current knowledge gets wrong.
# Specifically, that means I should be *very judicious* with the 'Duplicating' and 'Modifying' aliases, because if I ever improve those commands,
# I won't actually reap any benefit!
# tl;dr: these git-<alias>s SHOULD ALWAYS track what their corresponding git-<command> DOES, EVEN IF those commands change in the future
alias authors='git authors' # formerly from git-extras, but I don't like their implementation
alias authors-raw='git authors-raw'
alias bare='git bare'
alias branches='git branches'
alias config-editg='git config-editg'
alias config-editl='git config-editl'
alias gitdir='git gitdir'
alias ignored='git ignored'
alias intent-to-add='git intent-to-add'
alias logn='git logn' # log with numstats
alias logp='git logp' # log with patch
alias logs='git logs' # log with stats (+++-- indicators)
alias ls-files='git ls-files'
alias rainbow-all='git rainbow-all'       # explicitly --all form of rainbow output
alias rainbow-here='git rainbow-here'     # approx. git log --oneline --graph, specifically only the current history (no --all)
alias shallow='git shallow'               # a shallow clone (non-alphabetical to be beside its twin)
alias since='git since'                   # log with immediate --since argument (technically --since-as-filter, but THATS THE POINT!!!)
alias stats='git stats'                   # git show, with implicit --stat to change diff output to stats output
alias status-or-show='git status-or-show' # git status, if it would have any output. Otherwise git show
alias tags='git tags'                     # list the tags
alias unshallow='git unshallow'           # re-hydrate a shallow clone
alias unstash='git unstash'               # essentially `stash pop`
alias untracked='git untracked'           # something morally equivalent to 'status --untracked'
alias yesterday='git yesterday'           # 'since yesterday', potentially smarter

# 'Builtin-Shadowing, Duplicating' aliases
# These aliases are builtins that I *definitely* want shadowed all the time.
# For now, I'm NOT relying on permit-aliases-to-shadow-builtins or run-alias.
# Instead, for each of the builtin commands that I'd like to enhance, I'm just directly aliasing
# from the bash-land alias for the git-builtin name to the git-land enhanced command I'd like to use

# The `remote` bash command was formerly a function which (conditionally) adds -v to git-remote.
# I promoted it to a git alias. Git aliases aren't allowed to shadow git builtins,
# and `remotes` is the closest name I could pick in git-land, which is fine
# But! I also created the permit-aliases-to-shadow-builtins tech, AND I git-aliased `remote = remotes`
# So we *could* alias remote='git permit-aliases-to-shadow-builtins remote', or even rely on
# an existing `alias git='git permit-aliases-to-shadow-builtins'`, and just be a Non-Duplicating alias.
# Let's... not do that - it seems more straightforward to go directly there
# (and we won't be *as* vulnerable if I turn permit-aliases-to-shadow-builtins off)
alias remote='git remotes'

# 'Duplicating' aliases
# These could have been written as `alias X='git X'`, because they're
# all bash aliases for git aliases I've written.
# But! Because I don't ever expect to change what the underlying git alias does,
# I'd rather skip the indirection and just specify the correct behavior in the alias
alias co='git checkout'
alias intend='git intent-to-add' # sorta typo, but more trying to cover my bases on these names
alias intent='git intent-to-add' # sorta typo, but more trying to cover my bases on these names
alias staged='git diff --staged'
alias autostash='git pull --rebase --autostash' # implicit rebase is intentional. See the alias definition
alias register='mr register'                    # not a git command, but imagine `git alias register '!mr register'`

# 'Modifying' aliases
# Sometimes, I want my implicit git commands to have an additional parameter
# I can't add these to a git alias, because aliases can't overwrite existing commands

# If I'm `show`-ing a merge commit, please try to assume more that I'm looking for a `--diff-merge=on`-like behavior
# TODO: this is a little hinky. I'd really prefer if git had a config to actually turn ON --diff-merge,
#       rather than just set the default option for when it *does* get turned on
alias show='git show -m'

# rainbow should be implicitly --all from the cli
# This is an INTENTIONAL divergence from the behavior in git aliases, where it's rainbow-here.
# This makes sense because rainbow-here is more specific, and rainbow-all is more general.
# This way, an offhand invocation is more "the whole repo" and a git prefix means "what I'm working on now"
alias rainbow='git rainbow-all'

# always edit the global git config file
alias config-edit='git config-editg'

# list merge commits (like `log --merges`), but always assume I wanted to look at patches
# TODO: could potentially be super smart by looking at reflog and showing merges that have been *pulled* 'recently'
# nb: this might also learn something from `yesterday` if yesterday gets a hair smarter
alias merges='git merges -p'

# 'Not exactly duplicating' aliases
# Not all of these are duplicating a git alias, but they're not exactly typos either
# They exist to make my CLI invocations easier, and would be more properly considered
# as useful `j` aliases, than git alises (they allow j to be invoked in a git context,
# and they only j contexts that make sense in a git context)
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
