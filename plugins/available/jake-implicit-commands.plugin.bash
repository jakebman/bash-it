about-plugin "Some commands make no sense when invoked without an argument. Let's give them some!"

# TODO: several commands here leverate the `remotes` typo alias, which isn't correct - they should use something more explicit

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
	if [[ "$#" -eq 0 ]]; then
		# can't use `pager` here - no guarantee it respects +G, and we want to scroll to bottom
		history | less +G
	else
		history | ack --pager='less +G' "$@"
	fi
}

# formerly a simple `alias cat='bat --plain'`, but that doesn't handle this no-args use case
if _command_exists bat; then
	function cat {
		about 'allow you to use a bare `cat` as the normal cat; but any params essentially go to bat --plain'
		case "$#" in
			0)
				command cat "$@"
				;;
			1)
				bat --plain "$@"
				;;
			*)
				bat --style=header,grid,changes "$@"
				;;
		esac
	}
fi

function ts {
	about 'allow a bare `ts` to default to incremental timestamps from program start second: `ts -s "%H:%M:%.S"`'
	if [[ "$#" -eq 0 ]]; then
		command ts -s "%H:%M:%.S" "$@"
	else
		command ts "$@"
	fi
}

function diff {
	about "allow you to type the bare word 'diff' and get an automatic git diff, while still not harming the diff command"
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		# implicitdiff is my own tool, which does diff, but also falls back to git status
		git implicitdiff "$@"
	elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1"; then
		git diff "$@"
	else
		# TODO: this could be smarter for other people who don't hard-code LESS=-R, use a non-colorful pager, etc.
		# For now, I'm the only consumer, and this seems adequate
		(
			set -o pipefail # allow diff's failure to propagate outward past a pager's success
			command colordiff "$@" | pager
		)
	fi
}

function stat {
	about "allow you to type the bare word 'stat' and get an automatic (implicit-git) status, while not harming the stat command"
	if [[ "$#" -eq 0 ]]; then
		status "$@"
	else
		command stat "$@"
	fi
}

# TODO: I've gotten to the point of being frustrated at line wrapping messing with my diffs.
# TODO: I'd love it if this also looped into git diff, too
function diff-ignore-wrapping {
	about "Interpretting the input files as if they were markdown, calculate the diff. Basically, ignore line wrapping in the diff"
	echo "TODO"
}
alias markdown-diff=diff-ignore-wrapping
alias mddiff=markdown-diff

function delta {
	about 'allow you to type the bare word "delta" or "delta <git-command>" and get an automatic git-delta, while still not harming the delta command. Additional magic (TODO): `delta show`, if show aliases into git: show="git show ...", (or is a function that mentions git?) and runs that command with git replaced with git-delta'
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		# we choose implicitdiff here, because it serves diff well too
		git delta implicitdiff "$@"
	elif [[ "$#" -eq 1 ]] && _jake-special-single-args-for-diff "$1"; then
		# --help, --version, etc.
		command delta "$@"
	elif JAKE_SUPPRESS_GIT_SQUAWK=1 git is-valid-git-command "$1"; then
		# I 'trust' the is-valid-git-command I wrote, so...
		# file any grievances with is-valid-git-command, not here.
		# Update: lol - there's nothing is-valid-git-command can do about --help, so
		# for now we'll check the special args first.
		# TODO: if/when is-valid-git-command supports -- --help, use it here
		git delta "$@"
	elif [[ "$#" -eq 1 ]]; then
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
	if (( $# == 0 )); then
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
	else
		if _is_numeric "$1"; then
			# numeric first arg. Assume we're treeN
			treeN "$@"
		elif _in_array "-a" "$@"; then
			ltree "$@"
		else
			tree2 "$@"
		fi
	fi
}

function pstree {
	about "pstree, with assumed pagination and -a"
	command pstree -a "$@" | pager
}

function du {
	about "implicit ncdu if du's stdout is terminal"
	if [[ -t 1 ]]; then
		if [[ 0 -eq "$#" ]]; then
			# no guarantee that I have this
			if _command_exists ncdu; then
				ncdu -r
			else
				command du -h
			fi
		else
			# Still with terminal output; implicit -h
			command du -h "$@"
		fi
	else
		command du "$@"
	fi
}

function browse {
	about "allow you to type the bare word 'browse' and get an automatic gh browse, while not stepping on the toes of xdg-utils's browse command (a symlink to xdg-open), which takes arguments"
	if [[ "$#" -eq 0 ]]; then
		if remotes | grep --quiet gitlab; then
			glab repo view -w "$@"
		else
			gh browse "$@"
		fi
	else
		command browse "$@"
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
	if remotes | grep --quiet gitlab; then
		echo "running glab mr list"
		glab mr list "$@"
	else
		echo "running gh pr list"
		gh pr list "$@"
	fi
}

function fork {
	about "allow you to type the bare word 'fork' to fork in github or gitlab, whichever's relevant"
	if remotes | grep --quiet jake; then
		echo "You probably already have a fork. Figure it out"
		remotes
	elif remotes | grep --quiet gitlab; then
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
		(
			set -o pipefail
			command wc * | sort -n
		)
	else
		command wc "$@"
	fi
}

# Inspired by https://github.com/tpope/vim-obsession/issues/11
function vim {
	local file="${XDG_STATE_HOME:-${HOME?}/.local/state}/vim/jake-autosaved-session"
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		command vim -S "$file" "$@"
	else
		command vim "$@"
	fi
}
export -f vim # so that j receives it!

function realpath {
	about "allow you to type the bare word 'realpath' and automatically be cd'd there"
	if [[ "$#" -eq 0 ]]; then
		local nextdir="$(command realpath .)"
		if [[ "x${nextdir}" = "x${PWD}" ]]; then
			# Don't cd if we're already there. See also cddd's silly goose callout
			echo "silly goose. You're already there." >&2
			return 1
		else
			cd "$nextdir"
		fi
	else
		command realpath "$@"
	fi
}

function file {
	about "allow file to implicitly work against all files in the current folder. Also, filesystem errors propagate out (implicit -E)"
	(
		set -o pipefail
		if [[ "$#" -eq 0 ]]; then
			command file -E * | pager
		else
			command file -E "$@" | pager
		fi
	)
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

function shfmt {
	about 'report *sh (.bash, .sh, etc.) files in the current folder that need to be formatted, or take that output on the CLI or from stdin as-if via xargs (`shfmt|shfmt` or `shfmt $(shfmt)`)and format the listed files if they are safe to modify in git. Otherwise, forward to normal shfmt'
	if _has_flags "$@"; then
		command shfmt "$@"
	elif [[ "$#" -eq 0 ]] && ! [ -t 0 ]; then
		# shfmt doc's this case - if there are no args, stdin is used
		# I reserve my carveouts for bare terminal invocation, but shfmt can have `cat foo.bash | shfmt`
		# But it can't have `> shfmt` - there's no way in hell I'm going to sit here and a bash file manually
		command shfmt "$@"
	elif ! [ -t 0 ]; then
		# Stdin isn't the terminal and command shfmt doesn't have priority.
		# That means xargs-y input
		# Huh. "Splat the stdin into a series of cli arguments" can *almost* be done via `$(cat)`,
		# But it breaks on filenames with spaces.
		local -a files
		mapfile files
		_shfmt-xargsy "$@" "${files[@]}"
	elif [[ "$#" -eq 0 ]]; then
		# No args - we're in list-y land
		# TODO: if shfmt gets a --null flag, switch on the terminaly-ness of stdout and use xargsy --null behavior
		# in order to best support  the `shfmt | shfmt` use case
		command shfmt -l * 2>&1 | pager
	else
		# we have args. They aren't flags. Stdin is the terminal. Format them :)
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
