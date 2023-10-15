
# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Gonna try this out for a bit
alias cat='bat --plain'

# Allow j!! to work for a previous ack query
alias jack=j

# Because... tree should basically always be paged
alias tree=ltree

# because I want to know what the command *is*.
# These commands share many common flags, but these two flags are "(<command> only)", despite being very similar
alias pkill='pkill --echo'
alias pgrep='pgrep --list-full'

export CLICOLOR_FORCE="setting this value to ANYTHING forces 'tree' to use colors so we don't need to alias tree='tree -C'. See man(1) tree"

# requires maven 3.9+ https://maven.apache.org/configure.html#maven_args-environment-variable
export MAVEN_ARGS="-T1C"

# quit-if-one-screen allows less to simply dump the output to STDOUT when it would all fit on a single page
#   see https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW-CONTROL-CHARS enables color interpretation without allowing every raw control code through
#   (b/c that would make lines hard to track)
# tabs=2 condenses tabs to only two characters wide
export LESS="--quit-if-one-screen --quit-at-eof --no-init --RAW-CONTROL-CHARS --tabs=2"
# I like editing ~/.lessfilter, and this keeps getting in the way. This is the 'other' default for this setting
# That means that I could export XDG_DATA_HOME here instead of LESSHISTFILE, and less would implicitly use it
# I... don't want to do that :\ - I really want to preserve the 'should use the default' quality of these variables,
# and this shim lets me ~sorta~ do that
export LESSHISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/lesshst"
export LESSSTYLE=sas

if [ -f "$HOME/.cargo/env" ] ; then
	source "$HOME/.cargo/env"
fi

# TODO: I'd like to be able to apply these to stdin as well (the "||- your-command %s" variation).
# That'll take more infrastructure.
# Read more in $HOME/.lessfilter
if _command_exists lesspipe ; then # most likely; gets zip files too
  eval `lesspipe`
elif _command_exists "$HOME/.lessfilter" ; then # my custom shim for coloring lesspipe. lesspipe calls it
  _log_warn "lesspipe is not available, but ~/.lessfilter is present. Using that"
  export LESSOPEN="|| $HOME/.lessfilter %s"
elif _command_exists pygmentize ; then # fallback if somehow we don't have anything else useful
  # see `man less`, section "INPUT PREPROCESSOR"
  # We only use pygmentize on named files (not '||-') because
  # I don't really like the default colors that are guessed
  _log_warn "lesspipe and ~/.lessfilter are missing. Using pygmentize bare"
  export LESSOPEN='|| pygmentize -f 256 -O style="${LESSSTYLE:-default}" -g %s 2>/tmp/pygmentize-errors'
else
  _log_error "pygmentize is available via sudo apt install python-pygments"
fi

function vars {
  if [ "$#" -eq 0 ] ; then
    # magic incantation from the internet
    # Basically, prints the variables and functions of
    # the current bash session, but doesn't print the functions
    (set -o posix; set) | less
  else
     (set -o posix; set) | ack "$@"
  fi
}
alias var=vars # because I'm lazy
alias cars=vars # typo

function _jake-special-single-args-for-diff {
  case $1 in
    --help) return ;;
    --version) return ;;
    -h) return ;;
    -v) return ;;
  esac
  return 1;
}

function fidget {
	type fidget
	echo "TODO: loop this into jake-maintain-system tech"
	sleep 12
	( # subshell. Automatically undoes the cd ~
		cd ~
		jake-sdkman-update
		up
		if _command_exists win-git-update &>/dev/null ; then
			echo updating window git stuff too
			win-git-update
		fi
		apt-up
	)
}
alias fid=fidget
alias f=fidget
alias asdf=fidget
alias sdf=fidget


function typo {
	vim "${BASH_IT}/aliases/available/jake-typos.aliases.bash"
}
alias tyop=typo

function hgrep {
	about "grep your history (using ack)"
	history | ack "$@"
}

# TODO: these *-whiches are becoming a pattern. Can this be a bash-it plugin, maybe using _jq-ify tech?
# TODO: they need completions
# TODO: potentially try to use (shopt -s extdebug; declare -F quote) tech to jump to functions
#		see https://askubuntu.com/questions/354915/quote-command-in-the-shell/354929#354929
function vimwhich {
	vim "$(which "$1")"
}
alias vimw=vimwhich

function filewhich {
	# TODO: what if this was also able to call out that $1 is a function and/or alias, in addition to the executable it masks
	file "$(which "$1")"
}
alias filew=filewhich

function catwhich {
	# TODO: what if this was also able to print functions and aliases, too?
	# TODO: what if we follow aliases down to their roots?
	local where="$(which "$1")"
	cat "$(which "$1")"
	if [[ -t 1 ]] ; then # stdout is terminal. Cool to add info (see jake's bin/git)
		echo "${FUNCNAME[0]}: this file lives at '$where'"
	fi
}
alias catw=catwhich

function llwhich {
	ls -al "$(which "$1")"
}
alias llw=llwhich
alias lsw=llwhich

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
    git -c core.pager=delta implicitdiff "$@"
  elif [[ "$#" -eq 1 ]] && ! _jake-special-single-args-for-diff "$1" ; then
    # git-delta is aliased in git to to a git diff with delta as the pager
    git delta "$@"
  else
    command diff "$@"
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

function xml {
	if [[ "$#" -eq 0 ]] && [[ -t 0 ]]; then
		# reading from terminal, but no arguments on the CLI
		echo "insufficient arguments (this command doesn't take an implicit stdin well :( )"
		echo "usage: ${FUNCNAME[0]} <file>..."
		return 1
	fi

	# two-space indent, forcing newlines between elements w/o children
	xmlindent -i 2 -f "$@" | bat -pl xml
}

function xpath {
	local -a args
	args=("$@")
	if ! [[ -t 0 ]] ; then
		# stdin not from terminal. assume it's xml
		args+=('-')
	fi

	# insufficient args. Reading from stdin *does* add to this count
	if [[ "${#args[@]}" -lt 2 ]] ; then
		echo "insufficient arguments:"
		echo "usage: ${FUNCNAME[0]} <xpath> <file>..."
		return 1
	fi

	# Pass the output through the `xml` formatter, because xmllint --format --xpath is a one-result-per-line type of work.
	xmllint --xpath "${args[@]}" | xml
}
alias xmlpath=xpath

function doctor {
	about "just run bash-it doctor"
	time bash-it doctor
}
