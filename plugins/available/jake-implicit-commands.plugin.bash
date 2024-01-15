
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
    command diff "$@"
  fi
}

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
  # elif _jake-is-git-command "$1";
  #    git delta "$@"
  else
    command delta "$@"
  fi
}

function browse {
	about "allow you to type the bare word 'browse' and get an automatic gh browse, while not stepping on the toes of xdg-utils's browse command (a symlink to xdg-open), which takes arguments"
	if [[ "$#" -eq 0 ]] ; then
		gh browse "$@"
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
	local file="${HOME}/.vim/jake-autosaved-session"
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
		cd "$(command realpath .)"
  else
    command realpath "$@"
  fi
}
