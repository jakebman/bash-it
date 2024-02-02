
about-plugin "Some commands make no sense when invoked without an argument. Let's give them some!"

function _jake-special-single-args-for-diff {
  case $1 in
    --help) return ;;
    --version) return ;;
    -h) return ;;
    -v) return ;;
  esac
  return 1;
}

function diff {
  about "allow you to type the bare word 'diff' and get an automatic git diff, while still not harming the diff command"
  if [[ "$#" -eq 0 ]] ; then
    # $@ is unecessary, as it's empty. Keeps parallel structure, though.
    # implicitdiff is my own tool, which does diff, but also falls back to git status
    git implicitdiff "$@"
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    git diff "$@"
  else
    # TODO: colordiff?
    command diff "$@"
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
  about "allow you to type the bare word 'delta' and get an automatic git delta, while still not harming the delta command"
  if [[ "$#" -eq 0 ]] ; then
    # $@ is unecessary, as it's empty. Keeps parallel structure, though.
    # we choose implicitdiff here, because it serves diff well too
    git delta implicitdiff "$@"
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    # git-delta is aliased in git to run git with delta as the pager
	# and git-deltaDiff uses that to run diff
    git deltaDiff "$@"
  # TODO: with a command that can say if `delta X Y Z` should act like `git X Y Z`,
  # I can then dispatch wisely to `git delta X Y Z`. It's possible that only X really
  # matters for that evaluation
  # (Might be able to borrow that from the git command completion tech)
  # elif _jake-is-git-command "$1";
  #    git delta "$@"
  else
    command delta "$@"
  fi
}

function tree {
	about "always paginate tree output, and also try for a small peek even in large trees (use 'tree .' to override)"
	# I already set CLICOLOR_FORCE, so -C is not required, but it's more consistent to set it here
	# minor rant: why doesn't tree have a long option for this?
	if [[ "$#" -eq 0 ]] ; then
		command tree -C -L 3 --filelimit 25 "$@" | less
	else
		command tree -C "$@" | less
	fi
}

function browse {
	about "allow you to type the bare word 'browse' and get an automatic gh browse, while not stepping on the toes of xdg-utils's browse command (a symlink to xdg-open), which takes arguments"
	if [[ "$#" -eq 0 ]] ; then
		if remotes | grep --quiet gitlab ; then
			glab repo view -w "$@"
		else
			gh browse "$@"
		fi
	else
		command browse "$@"
	fi
}

function open {
	about "essentially identical to 'browse' - implicit gh browse, but runs the open command instead. (open is an alternatives, which usually picks xdg-open)"
	if [[ "$#" -eq 0 ]] ; then
		gh browse "$@"
	else
		command open "$@"
	fi
}

# Inspired by https://github.com/tpope/vim-obsession/issues/11
function vim {
	local file="${XDG_STATE_HOME:-${HOME?}/.local/state}/vim/jake-autosaved-session"
	if [[ "$#" -eq 0 ]] ; then
		# $@ is unecessary, as it's empty. Keeps parallel structure, though.
		command vim -S "$file" "$@"
	else
		command vim "$@"
	fi
}
export -f vim # so that j receives it!

function realpath {
  about "allow you to type the bare word 'realpath' and automatically be cd'd there"
  if [[ "$#" -eq 0 ]] ; then
		local nextdir="$(command realpath .)"
		if [[ "$nextdir" = "$PWD" ]] ; then
			# Don't cd if we're already there. See also cddd's silly goose callout
			echo "silly goose. You're already there." >2
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
	if [[ "$#" -eq 0 ]] ; then
		file *
	else
		command file "$@"
	fi
}
