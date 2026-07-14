about-plugin "Some commands make no sense when invoked without an argument. Let's give them some!"
# Load after wsl(-fast).plugin
# BASH_IT_LOAD_PRIORITY: 260

function _jake-special-single-args-for-diff {
	case $1 in
		--help) return ;;
		--version) return ;;
		-h) return ;;
		-v) return ;;
	esac
	return 1
}

function hgrep {
	about "grep your history (using ack)"
	# Modify ack's pager to ask less to start at the end of output. From `man less`:
	# "If a command line option begins with +, the remainder of that option is taken to be an
	#  initial command to less. For example, +G tells less to start at the end of the file..."
	# Also, suppress tilde padding - it's unnecessary here
	if [[ "$#" -eq 0 ]]; then
		# can't use `pager` here - no guarantee it respects +G, and we want to scroll to bottom
		history | less --tilde +G
	else
		history | ack --pager='less --tilde +G' "$@"
	fi
}


function dmesg {
	about 'enable `dmesg --human` if output is to the terminal. Also scroll to end if pager is less'
	if [[ -t 1 ]]; then
		LESS+=" +G" command dmesg --human "$@"
	else
		command dmesg "$@"
	fi
}

function xxd {
	about 'automatically page xxd output'
	if [[ -t 1 ]]; then
		# -R is like --color <when>
		command xxd -R always "$@" | pager
	else
		command xxd "$@"
	fi
}

function strings {
	about 'automatically page strings output'
	if [[ -t 1 ]]; then
		command strings "$@" | pager
	else
		command strings "$@"
	fi
}

# formerly a simple `alias cat='bat --plain'`, but that doesn't handle this no-args use case
# There's also an "or cd into it if it's a directory" feature
if _command_exists bat; then
	function cat {
		about 'allow you to use a bare `cat` as the normal cat; but any params essentially go to bat --plain. Or cd into a single-arg directory'
		case "$#" in
			0)
				command cat "$@"
				;;
			1)
				if [ -d "$1" ]; then
					# "Typo" - catt'ed into a dir. Probably meant to cd
					>&2 echo "Complex typo: meant to cd into a dir, but ran cat instead."
					>&2 echo "Complex typo: cd"
					cd "$@"
				else
					# implicit --plain from `bat --config-file`
					bat "$@"
				fi
				;;
			*)
				bat --style=header,grid,changes "$@"
				;;
		esac
	}
fi

function dirname {
	about 'allow a bare `dirname` to default to operating on the current $PWD. Not super helpful, but simple'
	if [[ "$#" -eq 0 ]]; then
		command dirname "$PWD"
	else
		command dirname "$@"
	fi
}

function alias-deep {
	about 'try git aliases if no bash aliases are found'
	if command alias "$@"; then
		return
	fi
	echo "No bash aliases found for $@ - trying git aliases too"
	# WARN: Jake-specific bash alias. Also found in git-extras
	git alias "$@"
}

function ts {
	about 'allow a bare `ts` to default to incremental timestamps from program start second: `ts -s "%H:%M:%.S"`'
	if [[ "$#" -eq 0 ]]; then
		command ts -s "%H:%M:%.S" "$@"
	else
		command ts "$@"
	fi
}

# TODO: would be cool to use getopt with known `command diff` flags, then any extras mean `git-diff`
function diff {
	about "allow you to type the bare word 'diff' and get an automatic git diff, while still not harming the diff command"
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		# implicitdiff is my own tool, which does diff, but also falls back to git status
		git implicitdiff "$@"
	elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1"; then
		git diff "$@"
	elif [ -t 1 ]; then
		# stdout is a terminal - we can color
		local -
		set -o pipefail # allow diff's failure to propagate outward past a pager's success

		# TODO: this could be smarter for other people who don't hard-code LESS=-R, use a non-colorful pager, etc.
		# For now, I'm the only consumer, and this seems adequate
		command colordiff "$@" | pager
	else
		command diff "$@"
	fi
}

function dd {
	about "sometimes I type dd when I meant d, which means diff"
	if [[ "$#" -eq 0 && -t 1 && -t 0 && -t 2 ]]; then
		>&2 echo "${FUNCNAME[0]} - no args, plus stdio are all terminals. ${FUNCNAME[0]} is not a cat. Running diff instead."
		>&2 echo
		diff "$@"
	else
		command dd "$@"
	fi
}

function _winget-implicit {
	about "allow a bare winget to list updates"
	if [[ "$#" -eq 0 ]]; then
		# Tell winget to list updatable tools, but also include pinned output
		# (That way we don't have to call `winget pin list` after this)
		winget update --include-pinned
	else
		winget "$@"
	fi
}
alias winget=_winget-implicit


function stat {
	about "allow you to type the bare word 'stat' and get an automatic (implicit-git) status, while not harming the stat command"
	if [[ "$#" -eq 0 ]]; then
		status "$@"
	else
		command stat "$@"
	fi
}

# Some variants on stat, for conversing with `status`
# The `status` command can sometimes farm out to mr status...
#      which runs git mr-status (per ~/.mrconfig)...
#      which dispatches to git is-mainline(-print-on-failure)...
#      which respects this setting
# The eventual result is that using this setting makes `status` go quicker or be more verbose
# verbose
alias statv="GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=jake.mainlineChecking GIT_CONFIG_VALUE_0=true stat"
# quick/quiet (my default at work)
alias statq="GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=jake.mainlineChecking GIT_CONFIG_VALUE_0=false stat"

function pop {
	about "do a git stash pop, or a popd(ir) if nothing's stashed"
	if [[ -z "$(git stash list)" ]]; then
		popd "$@"
	else
		git stash pop "$@"
	fi
}

function _base64_looks_like_base64 {
	about "if a string looks like a base64-encoded string. Heuristic. 'hello' is potentially a base64-encoded string"

	# Base64 is 26 lower + 26 upper + 10 digits (subtotal 62), plus two more characters ('+' and '/'), and up to 2 '=' for padding
	# There are other options for the last two characters, which I am ignoring:
	# https://en.wikipedia.org/wiki/Base64#Variants_summary_table
	# RFC 3501 uses +,
	# base64url uses -_
	# Paranoia requires the x-trick. X is also valid base64, so that's fine.
	(( ${#1} % 4 == 0 )) && [[ "X$1" =~ ^[a-zA-Z0-9+/]+=?=?$ ]]
}

function _implicit_base64 {
	about "allow base64 to operate on 1) multiple arguments (cat'd) and 2) string-arguments as-if they were files"
	# https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
	local -a flags
	local OPTS fileish

	OPTS=$(getopt --name base64_wrapper \
			--options diw: \
			--longoptions decode,ignore-garbage,wrap: \
			--longoptions help,version \
			-- \
			"$@")

	if [ $? != 0 ] ; then
		echo "Terminating..." >&2
		return 2
	fi

	eval set -- "$OPTS"
	while true; do
		case "$1" in
			-- )
				# -- is guaranteed to separate flags from arguments
				shift
				break
				;;
			* )
				flags+=("$1")
				shift
				;;
		esac
	done

	if [[ "$#" -eq 0 ]]; then
		# If no args, make the implicit '-' explicit
		eval set -- -
	fi

	for fileish; do # implicit `in "$@"`
		# need the x-tech because I'm concerned fileish could still be flag-like
		if [[ -f "$fileish" ]] || [[ x-x = "x${fileish}x" ]]; then
			command base64 "${flags[@]}" -- "$fileish"
		else
			command base64 "${flags[@]}" -- <<< "$fileish"
		fi
	done

	# Adding any flags (which would also include `-d`, but might not) disables this behavior
	if [ -t 1 ] && [[ "${#flags[@]}" -eq 0 ]] ; then
		# stdout is to the terminal and we aren't using any flags.
		# Let's try and also decode things
		for fileish; do # implicit `in "$@"`
			# need the x-tech because i'm concerned fileish could still be flag-like
			if ! [[ -f "$fileish" ]] && _base64_looks_like_base64 "$fileish"; then
				# This pattern looks for 9 or more characters. The '*'s in the middle helps separate
				# and the one at the end ensures we replace the entire string with its truncation.
				# Lengths of ...6,7,8 are all preserved. 9 and up becomes {first six}...
				local truncated="${fileish/#???*???*???*/${fileish:0:6}...}"

				echo
				echo "# And ${truncated} decodes to:"
				command base64 "${flags[@]}" -d -- <<< "$fileish"
			fi
		done
	fi
}
if getopt -T || (( $? != 4 )); then
	# non-GNU getopts will succeed -T. GNU getops returns 4
	_log_error "Need GNU getopt for base64 implicit command"
else
	alias base64=_implicit_base64
fi
alias unbase64='base64 -d'


# TODO: I've gotten to the point of being frustrated at line wrapping messing with my diffs.
# TODO: I'd love it if this also looped into git diff, too
function diff-ignore-wrapping {
	about "Interpretting the input files as if they were markdown, calculate the diff. Basically, ignore line wrapping in the diff"
	echo "TODO"
}
alias markdown-diff=diff-ignore-wrapping
alias mddiff=markdown-diff

function gitk {
	about "gitk should actually redirect through \`git gitk\` to allow me to keep argo-manifests out of there"
	if [[ "$#" -eq 0 ]]; then
		command git gitk --all "$@"
	else
		command git gitk "$@"
	fi
}

function delta {
	about 'allow you to type the bare word "delta" or "delta <git-command>" and get an automatic git-delta, while still not harming the delta command. Additional magic (TODO): `delta show`, if show aliases into git: show="git show ...", (or is a function that mentions git?) and runs that command with git replaced with git-delta'
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		# we choose implicitdiff here, because it serves diff well too
		git delta implicitdiff "$@"
	elif JAKE_SUPPRESS_GIT_SQUAWK=1 git is-valid-git-command -- "$1"; then
		# I 'trust' the is-valid-git-command I wrote, so...
		# file any grievances with is-valid-git-command, not here.
		git delta "$@"
	elif [[ "$#" -eq 1 ]] && ! _is_flag "$1"; then
		# git-delta is aliased in git to run git with delta as the pager
		# and git-deltaDiff uses that to run diff
		git deltaDiff "$@"
	else
		# anything else goes directly to delta
		command delta "$@"
	fi
}

function ltree {
	about "paginate (colored) tree output through your pager"
	# tree will be overwitten below, so 100% NEED to get past that with `command`
	if [ -t 1 ]; then
		command tree -C "$@" | pager
	else
		command tree "$@"
	fi
}

function treeN {
	about "customizable depth on ltree"
	param "1: tree depth"
	param "<rest>: Further args to tree."
	# Abuse the first param being always an arg to -L
	# We could totally shift $1 out... and then... put it first anyway?
	if (($# == 0)); then
		ltree "$@"
	else
		ltree -L "$@"
	fi
}

# tree2, tree3, tree4, tree5
for _i in {1..5}; do
	alias "tree${_i}=treeN ${_i}"
done
unset _i

complete -d ltree treeN tree{1..5}

function _in_array {
	about 'Succeeds if the first argument is stringly equal to any other element. Usage like _in_array 1 "${doesThisArrayHaveAOne[@]}"'
	local needle="$1" hay
	shift || return 1 # no needle - can't find it
	for hay; do       # implicit `in "$@"`
		[[ "x${needle}" = "x${hay}" ]] && return
	done
	return 1
}

function _is_numeric {
	about "Succeeds if all arguments match the /^[0-9]+$/ regex. Fails otherwise. (The empty string is not numeric)"
	local arg
	for arg in "$@"; do
		# nb: the numeric test from
		# https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
		# is unable to work properly in this situation, so we use bash's [['s extended regex (ERE) support
		# The 1 prefix prevents `arg=-a` from tricking test into doing something odd
		[[ "x${arg}" =~ ^x[[:digit:]]+$ ]] || return 1
	done
	return 0
}

function _has_flags {
	about "succeeds if any argument matches the /^-/ regex. Fails otherwise."
	local arg
	for arg; do # implicit in $@
		[[ "x${arg}" =~ ^x- ]] && return 0
	done
	return 1
}

function tree {
	about "tree, with assumed depth of 2, and filelimit 25. Numeric first argument becomes depth (see treeN). '-a' additionally implies infinite depth. If stdin is present, use jaketree on it instead"
	if ! [ -t 0 ]; then
		jaketree "$@"
	elif [[ "$#" -eq 0 ]]; then
		tree2 --filelimit 25 "$@"
	elif _is_numeric "$1"; then
		# numeric first arg. Assume we're treeN
		treeN "$@"
	elif _in_array "-a" "$@"; then
		ltree "$@"
	else
		tree2 "$@"
	fi
}

# I want to know what the command *is* when I pgrep or pkill.
# pgrep and pkill share many common flags, but these two flags I'm adding are "(<command> only)", despite being very similar
function pkill {
	about "pkill, but with --echo and paging if the output is terminal"
	if [ -t 1 ]; then
		command pkill --echo "$@" | pager
	else
		command pkill "$@"
	fi
}

function pgrep {
	about "pgrep, but with --list-full and paging if the output is terminal"
	if [ -t 1 ]; then
		command pgrep --list-full "$@" | pager
	else
		command pgrep "$@"
	fi
}

function pstree {
	about "pstree, with assumed pagination and -a"
	command pstree -a "$@" | pager
}

function du {
	about "implicit ncdu if du's stdout is terminal"
	if ! [[ -t 1 ]]; then
		# No terminal output. We don't modify the args to du
		command du "$@"
	elif [[ 0 -ne "$#" ]]; then
		# We have arguments, but terminal output. Add an implicit -h for readability
		command du -h "$@"
	elif _command_exists ncdu; then
		# No args, to the terminal. If ncdu exists, let's run it!
		ncdu -r
	else
		command du -h "$@"
	fi
}

function cp {
	about "It'd be cool if cp of one argument brings it into ."
	if [[ 1 -eq $# && -f "$1" ]]; then
		set -- "$@" .
	fi

	command cp -i "$@"
}

function df {
	about "implicit -h on df if stdout is a terminal"
	if ! [[ -t 1 ]]; then
		# No terminal output. We don't modify the args to df
		command df "$@"
	fi

	command df -h "$@"
}

function free {
	about "implicit -h on free if stdout is a terminal"
	if ! [[ -t 1 ]]; then
		command free "$@"
	fi
	command free -h "$@"
}

function update-motd {
	about "allow non-sudo users to run update-motd and get an implicit --show-only"

	if command update-motd "$@" 2>/dev/null; then
		# success!
		echo "# successfully ran update-motd ${@@Q}"
	else
		command update-motd --show-only "$@"
		echo # spacing
		echo "# This was an uncommitted preview, generated via fallback to update-motd --show-only ${@@Q}"
		echo "# You're getting the previewed output and this message instead of an opaque failure thanks to the bash function $FUNCNAME"
		return 1 # "Failure" might be too strong a word, but it definitely wasn't a successful update of the motd
	fi
}

# TODO: when you're in a node_modules subfolder, you can find a URL to browse via `jq .repository package.json`.
# This will make it easier to launch their readme, etc.
function browse {
	about "allow you to type the bare word 'browse' and get an automatic gh browse, while not stepping on the toes of xdg-utils's browse command (a symlink to xdg-open), which takes arguments"
	if [[ "$#" -ne 0 ]]; then
		# Have arguments - send them to the original browse command
		command browse "$@"
	elif git remote -v | grep --quiet gitlab; then
		glab repo view --web "$@"
	else
		gh browse "$@"
	fi
}

function mrs {
	about "gitlab or github [m]erge/[p]ull [r]equest[s]"
	local action=list # by default, list existing requests
	if (( $# )); then
		# Have args. Assume first is a numeric ID and/or we have flags
		action=view
	fi

	if git remote -v | grep --quiet gitlab; then
		glab mr "$action" "$@"
	else
		gh pr "$action" "$@"
	fi
}
alias prs=mrs

function pipeline {
	about "easy access to git{lab,hub} pipelines in the browser"
	if git remote -v | grep --quiet gitlab; then
		glab ci view --web "$@"
	else
		gh workflow view --web "$@"
	fi
}

# TODO: DUPLICATED CODE
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

function pulls {
	about "try to mange pull requests from the CLI"
	# List remotes with their urls
	if git remote -v | grep --quiet gitlab; then
		echo "running glab mr list"
		glab mr list "$@"
	else
		echo "running gh pr list"
		gh pr list "$@"
	fi
}

function fork {
	about "allow you to type the bare word 'fork' to fork in github or gitlab, whichever's relevant"
	# List remotes with their urls
	if git remote -v | grep --quiet jake; then
		echo "You probably already have a fork. Figure it out"
		git remote -v
	elif git remote -v | grep --quiet gitlab; then
		glab repo fork --remote "$@" || echo "I didn't test this. Probably needs a rewrite"
	else
		gh repo fork --remote "$@" || echo "I didn't test this either. Probably needs a rewrite"
	fi
}

function open {
	about "essentially identical to 'browse' - runs browse, but runs the open command on its arguments instead. (open is an alternatives, which usually picks xdg-open)"
	if [[ "$#" -eq 0 ]]; then
		# implicit browse function knows how to figure out whether to use gh or glab
		browse "$@"
	else
		command open "$@"
	fi
}

function wc {
	about "wc all files if there were no arguments. wc on a stdin tty feels... not optimal"
	if [[ "$#" -eq 0 ]] && [[ -t 0 ]]; then
		# no implicit $@ - not sure which side of * it goes on
		# sorted output, because it's pleasing to the eye
		local -
		set -o pipefail
		command wc * | sort -n
	else
		command wc "$@"
	fi
}

function realpath {
	about "allow you to type the bare word 'realpath' and automatically be cd'd there"
	if [[ "$#" -ne 0 ]]; then
		command realpath "$@"
		return # propagate return code from realpath command
	fi

	local nextdir="$(command realpath .)"
	if [[ "x${nextdir}" = "x${PWD}" ]]; then
		# Don't cd if we're already there. See also cddd's silly goose callout
		echo "silly goose. You're already there." >&2
		return 1
	else
		cd "$nextdir"
	fi
}

function file {
	about "allow file to implicitly work against all files in the current folder. Also, filesystem errors propagate out (implicit -E)"
	local -
	set -o pipefail
	if [[ "$#" -eq 0 ]]; then
		# A safer form of file -E * using find
		# -maxdepth 1 - find only the files under the starting-point
		# -mindepth 1 - exclude the starting point (at depth 0)
		# -printf '%P\0' - customizing a form of -print0 which strips the ./ prefix that -print0 gives
		# %P: File's name with the name of the starting-point under which it was found removed.
		find . -maxdepth 1 -mindepth 1 -printf '%P\0' | xargs --null file -E | pager
	else
		command file -E "$@" | pager
	fi
}

function _is_git_safe {
	about "determine if it's okay to modify a file 'automatically'. Essentially, if there aren't floating changes to it in the workdir"
	param "1: a file to check"
	if ! git ls-files --error-unmatch "$1" &> /dev/null; then
		printf "%s is not in git." "$1" >&2
		return 1
	fi
	if ! git diff --quiet -- "$1" &> /dev/null; then
		printf "%s has git modifications." "$1" >&2
		return 1
	fi
	return 0
}

function _shfmt_pager {
	eval "${SHFMT_PAGER:-bat --language=bash}"
}

function shfmt {
	about 'report *sh (.bash, .sh, etc.) files in the current folder that need to be formatted, allow `shfmt $(shfmt)` to be git-aware'
	if _has_flags "$@"; then
		command shfmt "$@" | _shfmt_pager
	elif ! [ -t 0 ]; then
		# TODO: it would be nice to peek the first line. If it's a file, we'll xargs ourselves. Otherwise, be a formatting pager
		# Stdin isn't the terminal and command shfmt doesn't have priority.
		# We'll just format the input, but with a good coloring pager
		command shfmt "$@" | _shfmt_pager
	elif [[ "$#" -eq 0 ]]; then
		# No args, stdin is the terminal - we're in list-y land
		command shfmt -l * 2>&1 | pager
	else
		# we have args. They aren't flags. Stdin is the terminal. Format them, respecting git safety :D
		_shfmt-xargsy "$@"
	fi
}
function _shfmt-xargsy {
	local file
	local -a modified
	local -a skipped
	for file; do # implicit in $@
		if command shfmt -d "$file" &> /dev/null; then
			# shfmt didn't find any complaints with this file
			: # Nothing to do
		elif ! _is_git_safe "$file"; then
			# Not git safe; have a message printed about that.
			echo " And shfmt would like to modify it." >&2
			skipped+=("$file")
		else
			# shfmt wants to make a change, and it is allowed to
			# So, let's run shfmt in-place, printing the file name if modified
			# IF THIS IS MODIFIED, MODIFY THE MANUAL STEP BELOW
			local mod="$(shfmt -w -l "$file")"
			if [[ -n "$mod" ]]; then
				modified+=("$file")
			fi
		fi
	done

	echo # blank line
	if [[ 0 -eq "${#modified}" ]]; then
		echo "No modifications performed."
	else
		printf "Modified:\n"
		printf " * %s\n" "${modified[@]}"
	fi

	if [[ 0 -ne "${#skipped}" ]]; then
		echo # blank line
		echo "Use the following command to intentionally modify skipped files (or use shfmt -d to preview the diffs):"
		printf "shfmt -w -l" # THIS DEPENDS ON THE SCRIPT ABOVE, AND SHOULD MATCH
		printf " \\\\\n\t%q" "${skipped[@]}"
	fi
}
