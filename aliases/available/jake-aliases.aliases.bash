# shellcheck shell=bash
about-alias "Jake's custom commands that are aliases"

# They're functionally aliases; so sue me
# (They also have typo aliases)
function lls {
	local humanReadable
	if [ -t 1 ]; then
		# stdout is terminal
		humanReadable=--human-readable
	fi
	# an expanded form of -alF, from bash-it's `alias ll='ls -alF'`
	# But, I prefer -[-A]lmost-All over -[-a]ll
	# -l is --long-listing, but has no long analog
	# And we only --human-readable if stdout is a terminal
	ls -l --almost-all --classify $humanReadable --color "$@" | pager
}
# Bash Minutae:
# We *could* use the previously-declared `alias ll=..` within `function lls` above.
# We *could* then override `alias ll=` with `=lls`, *and everything would work*
# This is FINE by the rules of bash! The prior alias would have been *expanded* during
# the creation of the function, so there's no circular reference
alias ll=lls
# Override bash-it's --all with --Almost-All
alias l='ls --almost-all --classify'

# I really like permament differences
alias watch='watch --differences=permanent'

function make {
	if [ -t 1 ]; then
		time colormake "$@"
	else
		command make "$@"
	fi
}

# The completion mechanisms have no actual reason to believe that my make function has any actual relationship to the make command.
# TODO: is there a way to bring the bash-completions mechanisms into the loop on this?
source /usr/share/bash-completion/completions/make && complete -F _make make

# Sometimes I use this name for the command rather than its normal name. Oops.
alias maven=mvn

# ll, plus other flags
alias lla='ll -a' # Beautiful - this used to be a no-op alias, but I changed ll to have -A instead
alias llh='ll -h'
alias llt='ll -t'
alias llht='ll -ht'
alias llth='ll -ht' # would be a typo, but I don't actually know which should be canonical

alias untar='tar xf' # simply untar a file

# The rest of the file is entirely git commands that... I don't care to add git to

# 'Magic' aliases - smarter than their corresponding git command (they can see more Jake context)
# TODO: these are potentially 'implicit' commands a la jake-implicit-commands
# ... or even as their own implicit-mr plugin

# pull can have special meaning in $HOME, or other places with mr configs
function pull {
	if [ "$#" -ne 0 ]; then
		# If we have arguments, it's because I'm thinking this is a git pull
		git pull-unless-detached "$@"
	elif [ ~ = "$PWD" ] || [ -f .mrconfig ]; then
		# Get local coloring from git pull, even through mr up
		# TODO: this eats mr error output like this:
		# # In ~/wsl-projects/remarkable
		# # NB: `pull` isn't an mr command. `mr up` was intended
		# → mr pull
		# mr: illegal checkout command "mv kindle2pdf pdf2remarkable || git clone 'git@github.com:teticio/pdf2remarkable.git' 'pdf2remarkable'" in untrusted /home/jakebman/wsl-projects/remarkable/.mrconfig line 115
		# (To trust this file, list it in ~/.mrtrust.)

		local -x GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
		GIT_CONFIG_COUNT=1
		GIT_CONFIG_KEY_0=color.ui
		GIT_CONFIG_VALUE_0=always

		# TODO: can I refactor *this* to a git setting, accessible via `git pager mr-up`?
		local -a PAGER=(cat) # Normally, we don't have to do paging
		if [[ "x$(basename "$PWD")" == *junk-drawer* ]]; then
			# Directly within a Junk Drawer. Allow updating it
			local -x UPDATE_JUNK_DRAWER=any-string-value

			>&2 echo "Running pull in a junk drawer. Enabling UPDATE_JUNK_DRAWER"
			# ... but the junk drawer needs a pager. It can follow the output, though
			# (also, ask less to tee its input to an update log)
			PAGER=(less --tilde +F --LOG-FILE="update-log.$(date --iso-8601=seconds)")
		fi

		# yes, there's a .mrconfig in ~, but there's no disk access to check $PWD first
		mr up "$@" |& awk --assign boredRatio="${JAKE_STATUS_BORED_RATIO:-42}" '
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
			!/^mr update:/ &&
				!/^Already up to date./ &&
				!/^Junk Drawer: Skipping junk drawer project.$/ &&
				!/^Not on a branch. Pull could accidentally merge. Fetching instead.$/ &&
				!/^Fetching / {
				if (info) {
					info = info "\n"
				}
				info = info $0
			}

			/^Fetching / {
				$1 = ""
				repo = repo "," $0;
			}

			/^$/ {
				# with a hundred tracked repos, I want some intermediate output
				emptyLine+=1
				if(!(emptyLine % boredRatio)) {
					repo=repo " (progress marker after " emptyLine " quiet entries)"
					print_and_empty_info()
				}
			}

			# When we are done, we print the last repo, even if it had empty info
			# this also serendipituously covers the final summary "mr status: finished (86 ok)"
			END {
				print_and_empty_info()
			}
		' | "${PAGER[@]}"
	else
		# Technically, we know there are no args to pass to pull here, but it keeps parallel structure
		# When we fallback to git fetch in case we're in a situation where the remote branch is deleted (merged)
		# or never existed (local draft branch), I don't expect fetch to take the same arguments as pull even if
		# they're both empty
		if ! git pull "$@"; then
			>&2 echo "${FUNCNAME}: git pull failed for some reason. Trying git fetch as fallback"
			git fetch
		fi
	fi
}

function status {
	# see pull, above
	local status=0
	if [ ~ = "$PWD" ] || [ -f .mrconfig ]; then
		mr status "$@" | awk --assign boredRatio="${JAKE_STATUS_BORED_RATIO:-42}" '
			function print_and_empty_info() {
				if (! repo) return
				print "#", repo
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

				next
			}

			# Empty line. Usually between reports. Can be several between
			# the end of one repo status and another. I dunno why.
			# But, with a hundred tracked repos, I want some intermediate output
			# So this is it:
			/^$/ {
				emptyLine+=1
				if(!(emptyLine % boredRatio)) {
					repo=repo " (progress marker after " emptyLine " quiet entries)"
					print_and_empty_info()
				}

				next
			}

			# Nonempty, non-start lines are the report for `repo`
			{
				info = info $0 "\n"
			}

			# When we are done, we print the last repo, even if it had empty info
			# this also serendipituously covers the final summary "mr status: finished (86 ok)"
			END {
				print_and_empty_info()
			}
		' | git pager jake-custom-mr-status
		# TODO: did I harm this exit code with the awk processing?
		status="$?"

		echo "git repo status:"
	fi

	# I want an unconditional git status. We *can* also include mr, above, but this *must* happen anyway
	# (but if mr status fails, it would be nice to propagate that failure here, too)
	git status "$@" && return $status
}

function mr-unskip {
	mr --force -d "${1?Need an mr dir to run}" checkout
}
alias unskip=mr-unskip

function _mr-unskip {
	local -a candidates
	local item completeMe=$2
	# I have good docs on mapfile in jake-install-tools
	# TODO: I'd love a better way to read ini file headers properly
	# -t to remove trailing newline delimiter - not used in other places where I used the zero string
	mapfile -t candidates < <(
			grep '^\[' .mrconfig |
				tr -d [] |
				grep -Ev "^(DEFAULT|ALIAS)$" |
				sort
			)
	COMPREPLY=()
	for item in "${candidates[@]}"; do
		if [ ! -d "$item" ] && [[ x"$item" = x"$completeMe"* ]]; then
			COMPREPLY+=("$item")
		fi
	done


	#printf "{%s}\n" "${COMPREPLY[@]}"
}
complete -F _mr-unskip mr-unskip

function realpath-and-rainbow {
	about "preceed a rainbow with a realpath, if relevant"
	realpath 2> /dev/null # specifically want the zero-arg "go to the real path" behavior

	if [[ "$#" -eq 0 ]]; then
		git rainbow-all "$@"
	else
		git rainbow "$@"
	fi
}

# NB: subshell function
function relocate (
	about "move a file to a new location, leaving a symlink at the old location. If the file is tracked in git, git-relocate is used instead"
	local source=${1?Need a source}
	local destination=${2?Need a destination}
	if git ls-files --error-unmatch "$source" &>/dev/null; then
		# is tracked by git, per google AI result for "is git tracking a file"
		git relocate "$source" "$destination"
		return
	fi

	set -o errexit
	local a_s=$(realpath "$source")
	mv --interactive "$source" "$destination"
	local a_d=$(realpath "$destination")
	if [ -d "$destination" ]; then
		# symbolic target should be the new filename
		a_d+="/$(basename "$source")"
	fi
	ln --symbolic --relative --interactive --verbose "$a_d" "$a_s"
)

function _jake-banner-display {
	about "display a banner, but don't care if it fails"
	# figlet doesn't have --long --options :(
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

# TODO: this doesn't offer to add untracked files. If there are no patches, can it try that instead, please?
function addp {
	about "reset tabstops in git add to something similar to git's core.pager= less --tabs=3,5, but with 4 spaces instead"
	# TODO: would this make sense to try under termcap's ti/te state? Would that be helpful, or weird because the output is lost?
	# https://askubuntu.com/questions/984209/how-does-less-switch-to-the-text-then-back-to-the-prompt
	# (DO NOT do this for restore - I want the patches stored in the terminal scrollback buffer)
	# put the margin in by one character (+m1), and use 'COBOL compact format extended' (-c3)
	# neither tabs nor clear has --long --options
	tabs +m1 -c3
	clear -x

	_jake-banner-display "GIT ADD"
	git add --patch "$@"

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

# TODO: Duplicated code
function _has_flags {
	about "succeeds if any argument matches the /^-/ regex. Fails otherwise."
	local arg
	for arg; do # implicit in $@
		[[ "x${arg}" =~ ^x- ]] && return 0
	done
	return 1
}

# TODO: this doesn't get automatic completion. Can we add some?
function cherry-pick {
	about "git cherry-pick, but if it's not a --continue/--abort/etc., try to include the (cherry picked from ...)"
	if [ "$#" -eq 1 ] && _is_flag "$1"; then # likely a --continue/etc.
		git cherry-pick "$@"
	else
		git cherry-pick -x "$@"
	fi
}

# commit without any (non-transparent) flags means that any files mentioned are added and the -m is "$*"
# TODO: move this function to a git-alias. Calling it will get the proper git squawking behavior
# TODO: if no args, and the stage is empty, we should do an add -p, then continue on to the 'provide this commit message' step. Current behavior is 'status'
# TODO: If this moves to a git alias (`git commit-like-jake-wants`), then I no longer need to suppress git squawk.
#       ... I should formalize what that means somewhere.
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

	# No flags are passed - the commit message is "$*", and we implicitly addp any args that are files
	# TODO: if there are no arguments at all, I want something like "here's the changes.. what's your message? what's to commit? are you sure you wanted that message?"
	if ! _has_flags "$@"; then
		local arg added
		for arg; do # implicit in "$@"
			if [ -f "$arg" ]; then
				# is a file. implicitly intend to add, then interactively add diffs from it
				JAKE_SUPPRESS_GIT_SQUAWK=1 git add --intent-to-add "$arg"
				JAKE_SUPPRESS_GIT_SQUAWK=1 addp "$arg"
				added=yes
			fi
		done
		if [ -v args ] || [ -v added ]; then
			# We either have added flags, or specifically know we added files from $@
			:
		elif JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --no-renames --quiet; then
			# No staged changes. Commit will fail. User probably wants to select some changes to add
			# --no-renames tells git to identify a difference when one file is deleted and another added,
			# even if those files "happen" to have the same contents. We positively want that behavior.
			JAKE_SUPPRESS_GIT_SQUAWK=1 add # dunno which file you wanted, but go ahead and do an interactive add
			# STILL no changes. Commit will obviously fail. User probably a little confused
			if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --no-renames --quiet; then
				echo
				echo "no changes for commit message '$1'. No commit created. Thank you."
				echo
				git diff --staged --quiet # get the git squawk, but only if the outer test failed
				# TODO: no squawk occurs if Ctrl+C kills us
				return 1
			fi
		fi

		git commit "${args[@]}" --message "$*"
	else
		git commit "${args[@]}" "$@"
	fi
}

# Amend a prior commit. Try to guess the user's intent.
# Nice feature: if you committed some changes (and therefore didn't change the message),
# re-running this gives you the ability to immediately(-ish) change the message
# TODO: this could follow commit's argument-juggling tech, from above
function amend {
	if JAKE_SUPPRESS_GIT_SQUAWK=1 git is-clean-quiet; then
		# No changes can possibly be `add`-ed. We're obviously editing the message
		git commit --amend
		return
	fi

	# if nothing is staged, offer the ability to add changes:
	if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --no-renames --quiet; then
		JAKE_SUPPRESS_GIT_SQUAWK=1 add
	fi

	if JAKE_SUPPRESS_GIT_SQUAWK=1 git diff --staged --no-renames --quiet; then
		# No staged changes, even after offering `add`
		git commit --amend
	else
		# There are staged changes. We'll keep the prior message
		git commit --amend --no-edit
	fi
}

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
	git restore --patch "$@"

	local out="$?"
	tabs +m0
	return "$out"
}

function unstage {
	if [ "$#" -eq 0 ]; then
		_jake-banner-display "GIT RESTORE --STAGED"
		git unstage --patch "$@" # $@ is empty, but this is more consistent with the other branch
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

# TODO: if you're in an mr area, and the current name, *or remote* is already made, offer mr-unshallow
function clone {
	local git_command=clone
	local retcode
	if [[ "x$(basename "$PWD")" == *junk-drawer* ]] &&
		mr -d this-mr-repo-name-does-not-exist-and-is-used-to-check-if-we-skip-repos status &>/dev/null; then
		# special case: shallow clone from within skipping junk-drawers
		git_command=shallow
		echo "We're in a junk drawer with skip=lazy or similar - using a shallow clone"
	fi

	git $git_command "$@" || return

	if [[ -f .mrconfig ]]; then
		# https://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/
		local dir
		for dir; do :; done

		# basename, stripping a suffix
		dir="$(basename --suffix=.git "$dir")"

		if [[ -d "$dir" ]]; then
			mr register "$dir"
		else
			echo "please manaully register $* with mr"
		fi
	fi

	return 0 # the git clone above succeeded. We don't care if mr register did.
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
alias ls-files='git ls-files'
alias log='git log'
alias mergetool='git mergetool'
alias shortlog='git shortlog'
alias submodule='git submodule'
alias tag='git tag'
alias reflog='git reflog'
alias rev-parse='git rev-parse'
alias worktree='git worktree'
alias bisect='git bisect'
# git-extras
alias abort='git abort'
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
alias co='git co'
alias config-editg='git config-editg'
alias config-editl='git config-editl'
alias gitdir='git gitdir'
alias push--='git push--' # Intended to be push --force-with-lease
alias pull--='git pull--' # A pull that is force-y: essentially reset the current branch to its upstream; changing the working tree. Try to be safe about it.
alias ignored='git ignored'
alias intent-to-add='git intent-to-add'
alias logn='git logn' # log with numstats
alias logp='git logp' # log with patch
alias logs='git logs' # log with stats (+++-- indicators)
alias ls-untracked='git ls-untracked'
alias ls-ignored='git ls-ignored'
alias rainbow-branches='git rainbow-branches'
alias rainbow-all='git rainbow-all'       # explicitly --all form of rainbow output
alias rainbow-here='git rainbow-here'     # approx. git log --oneline --graph, specifically only the current history (no --all)
alias shallow='git shallow'               # a shallow clone (non-alphabetical to be beside its twin)
alias since='git since'                   # log with immediate --since argument (technically --since-as-filter, but THATS THE POINT!!!)
alias changed-since='git changed-since'   # like since, but only lists the files changed, piping through `jaketree` when showing on the terminal
alias stats='git stats'                   # git show, with implicit --stat to change diff output to stats output
alias status-or-show='git status-or-show' # git status, if it would have any output. Otherwise git show
alias tags='git tags'                     # list the tags
alias unshallow='git unshallow'           # re-hydrate a shallow clone
alias unstash='git unstash'               # essentially `stash pop`
alias untracked='git untracked'           # something morally equivalent to 'status --untracked'
alias yesterday='git yesterday'           # 'since yesterday', potentially smarter
alias today='git today'                   # like yesterday, but more recent. Allowed to be identical to yesterday, though.

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
# TOMBSTONE: this Duplicating alias failed. Preserving evidence of 1/6 failure rate
# alias co='git checkout'
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
# My preferred way to type this command. Formerly a typo.
alias edit-config=config-edit

# list merge commits (like `log --merges`), but always assume I wanted to look at patches
# TODO: could potentially be super smart by looking at reflog and showing merges that have been *pulled* 'recently'
# nb: this might also learn something from `yesterday` if yesterday gets a hair smarter
alias merges='git merges --patch'

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
