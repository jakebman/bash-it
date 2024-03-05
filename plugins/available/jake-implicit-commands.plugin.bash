about-plugin "Some commands make no sense when invoked without an argument. Let's give them some!"

function _jake-special-single-args-for-diff {
	case $1 in
		--help) return ;;
		--version) return ;;
		-h) return ;;
		-v) return ;;
	esac
	return 1
}

# formerly a simple `alias cat='bat --plain'`, but that doesn't handle this no-args use case
function cat {
	about 'allow you to use a bare `cat` as the normal cat; but any params essentially go to bat --plain'
	if [[ "$#" -eq 0 ]]; then
		command cat "$@"
	else
		bat --plain "$@"
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

# TODO: I've gotten to the point of being frustrated at line wrapping messing with my diffs.
# TODO: I'd love it if this also looped into git diff, too
function diff-ignore-wrapping {
	about "Interpretting the input files as if they were markdown, calculate the diff. Basically, ignore line wrapping in the diff"
	echo "TODO"
}
alias markdown-diff=diff-ignore-wrapping
alias mddiff=markdown-diff

function delta {
	about 'allow you to type the bare word "delta" or ("delta git-command" - TODO) and get an automatic git-delta, while still not harming the delta command. Additional magic (TODO): `delta show`, if show aliases into git: show="git show ...", (or is a function that mentions git?) and runs that command with git replaced with git-delta'
	if [[ "$#" -eq 0 ]]; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		# we choose implicitdiff here, because it serves diff well too
		git delta implicitdiff "$@"
	elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1"; then
		# git-delta is aliased in git to run git with delta as the pager
		# and git-deltaDiff uses that to run diff
		git deltaDiff "$@"
	# TODO: with a command that can say if `delta X Y Z` should act like `git X Y Z`,
	# I can then dispatch wisely to `git delta X Y Z`. It's possible that only X really
	# matters for that evaluation
	# (Might be able to borrow that from the git command completion tech in /usr/share/bash-completion/completions/git)
	# elif _jake-is-git-command "$1";
	#    git delta "$@"
	else
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
	ltree -L "$@"
}

# tree2, tree3, tree4, tree5
for _i in {2..5}; do
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
	about "Succeeds if all arguments match the /[0-9]+/ regex. Fails otherwise. (The empty string is not numeric)"
	local arg
	for arg in "$@"; do
		# nb: the numeric test from
		# https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
		# is unable to work properly in this situation, so we use bash's [['s extended regex (ERE) support
		# The 1 prefix prevents `arg=-a` from tricking test into doing something odd
		[[ "x${arg}" =~ x[[:digit:]]+ ]] || return 1
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
	about "tree, with assumed depth of 2, and filelimit 25. Numeric first argument becomes depth (see treeN). '-a' additionally implies infinite depth"
	if [[ "$#" -eq 0 ]]; then
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
	about "essentially identical to 'browse' - implicit gh browse, but runs the open command instead. (open is an alternatives, which usually picks xdg-open)"
	if [[ "$#" -eq 0 ]]; then
		gh browse "$@"
	else
		command open "$@"
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
	about "allow file to implicitly work against all files in the current folder"
	if [[ "$#" -eq 0 ]]; then
		command file * | pager
	else
		command file "$@" | pager
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

function shfmt {
	about "report *sh (.bash, .sh, etc.) files in the current folder that need to be formatted, or take that output via xargs and format the files if they're safe to modify in git. Otherwise, forward to normal shfmt"
	if [[ "$#" -eq 0 ]]; then
		command shfmt -l * 2>&1 | pager
	elif _has_flags "$@"; then
		command shfmt "$@"
	else
		local file
		local -a modified
		for file; do # implicit in $@
			if _is_git_safe "$file"; then
				# run shfmt in-place, printing the file name if modified
				local mod="$(shfmt -w -l "$file")"
				if [[ -n "$mod" ]]; then
					modified+=("$file")
				fi
			else
				# rely on _is_git_safe to say 'why'
				echo " Not modifying via implicit shfmt" >&2
			fi

		done
		if [[ 0 -eq "${#modified}" ]]; then
			echo "No modifications performed"
		else
			printf "Modified:\n"
			printf " * %s\n" "${modified[@]}"
		fi

	fi
}
