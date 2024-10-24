# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export BASH_IT_CURL_PAGER='bat --style=numbers'
export MANPAGER="less  --lesskey-src '${HOME}/.config/lesskey-no-gotoend-on-q'"
export WATCH_INTERVAL=1.2 # I'm a little impatient. It's nice to have this be a little faster than the full 2s

if [ -v WSL_WINDOWS_USER_HOME ]; then
	if [ -v KUBECONFIG ]; then
		KUBECONFIG+=":"
	fi
	# TODO: refactor out the "is windows a viable thing to add to KUBECONFIG" and "ensure ~/.kube/config is in KUBECONFIG"
	KUBECONFIG+="${WSL_WINDOWS_USER_HOME}/.kube/config:${HOME}/.kube/config"
	export KUBECONFIG
fi
# NB: Enhancement only provided by the aws-enhancements plugin.
# I'm exporting AWS_BROWSER even though it's only respected by aws-enhancements
# just in case I write a non-bash-it script in ~/bin that might care
export AWS_BROWSER=wslview
_BASH_IT_AWS_AUTOLOGIN_EXCEPTIONS+=(login loggedin logout)

# Allow j!! to work for a previous ack query
alias jack=j
# I want j!! to work for a previous pj query, too
alias jpj=j

# Alias to look for my files
alias jake='j --jake'

# TODO: can I get autocomplete on a single tab?

# because I want to know what the command *is*.
# These commands share many common flags, but these two flags are "(<command> only)", despite being very similar
alias pkill='pkill --echo'
alias pgrep='pgrep --list-full'

# requires maven 3.9+ https://maven.apache.org/configure.html#maven_args-environment-variable
export MAVEN_ARGS="-T1C"

# Get timing output in maven. Doesn't require maven >= 3.9 (sets java system properties, not maven switches)
MAVEN_OPTS+=" -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss.SSS"
export MAVEN_OPTS

# quit-if-one-screen allows less to simply dump the output to STDOUT when it would all fit on a single page
#   see https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
# no-init disables that weird 'second screen' behavior, which I don't like
# ignore-case is actually smartcase - all-lowercase is case-insensitive; add an uppercase to require case matching
# RAW-CONTROL-CHARS enables color interpretation without allowing every raw control code through
#   (b/c that would make lines hard to track)
# tabs=2 condenses tabs to only two characters wide
# jump-target=.2 puts the searched-for line 2/10ths of the way down the screen, rather than at the top line
#   (Heads up! 0.2 does not work. I tried, and learned that)
#   This also applies to 'go to line' and 'go to tag' commands
# SEARCH-SKIP-SCREEN ensures that new searches start below the jump-target line, and not the top of the screen
#   Repeated searches (with n/N) already did this, but if you search for something new
#        you would otherwise be searching 2/10ths of the screen *up* from where you started
#   It's also worth noting that this is *per line*, so following matches on the same line are also skipped
# use-color gets a nice light cyan color on some of less's UI elements
# <trailing space> permits `LESS+=--new-flag some command` invocations
# There's some cool discussion on the value of these flags used in SYSTEMD_LESS in the `man systemctl` docs
export LESS="--quit-if-one-screen --quit-at-eof --no-init --ignore-case --RAW-CONTROL-CHARS --tabs=2 --jump-target=.2 --SEARCH-SKIP-SCREEN --use-color "
# I liked editing ~/.lessfilter (which is now in XDG_CONFIG_HOME), and this kept getting in the way.
# Still, this is the proper XDG-like location for this file. Since it's the 'other' default for this setting,
# I could export XDG_DATA_HOME here instead of LESSHISTFILE, and less would implicitly use it.
# BUT I don't want to do that :\ - I really want to preserve the 'should use the default' quality of the XDG variables,
# and this shim lets me ~sorta~ do that
export LESSHISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/lesshst"
export LESSSTYLE=sas # respected by lessfilter in XDG_CONFIG_HOME (not actually a LESS env variable)

if [ -f "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
fi

# TODO: I currently don't have a diff-sorted/sorted-diff/sortdiff/diffsort command (a `sort` variant of jqdiff), and I want one

# TODO: I'd like to be able to apply these to stdin as well (the "||- your-command %s" variation).
# That'll take more infrastructure.
# Read more in $XDG_CONFIG_HOME/lessfilter or ~/.lessfilter
if _command_exists lesspipe; then # most likely; gets zip files too
	eval $(lesspipe)
elif _command_exists "${XDG_CONFIG_HOME:-${HOME}/.config}/lessfilter"; then # my custom shim for coloring lesspipe. lesspipe calls it
	_log_warning "lesspipe is not available, but XDG_CONFIG_HOME/lessfilter is present at ${XDG_CONFIG_HOME:-${HOME}/.config}/lessfilter. Using that"
	export LESSOPEN="|| ${XDG_CONFIG_HOME:-${HOME}/.config}/lessfilter %s"
elif _command_exists "$HOME/.lessfilter"; then # a legacy location for lessfilter
	_log_warning "lesspipe is not available, but ~/.lessfilter is present. Using that"
	export LESSOPEN="|| $HOME/.lessfilter %s"
elif _command_exists pygmentize; then # fallback if somehow we don't have anything else useful
	# see `man less`, section "INPUT PREPROCESSOR"
	# We only use pygmentize on named files (not '||-') because
	# I don't really like the default colors that are guessed
	_log_warning "lesspipe is mising and lessfilter is missing from both ~ and XDG_CONFIG_HOME. Using pygmentize bare"
	export LESSOPEN='|| pygmentize -f 256 -O style="${LESSSTYLE:-default}" -g %s 2>/tmp/pygmentize-errors'
else
	_log_error "pygmentize is available via sudo apt install python-pygments"
fi

function find-ack {
	ack -f "$@"
}
alias ack-find=find-ack

function files {
	about "list the files of an apt package; or run the file command on all files in a directory (defaulting to . if there are no arguments)"

	if [[ "$#" -eq 0 ]]; then
		file # the no-arg behavior I added to file is to list the files in .
	elif [[ -d "$1" ]]; then
		for arg; do # implicit in $@
			file "$arg" "${arg}/"*
		done
	else
		# TODO: apt-file has a 'progress bar'-like thing. It'd be cool to be able to borrow that
		echo "(This command takes a long time, and it's eating apt-file's progress bar. Sorry.)"
		(dpkg -L "$@" || apt-file list "$@") | pager
	fi
}

function vars {
	# TODO: this is both better and worse than printenv (printenv recognizes functions, but doesn't do partial matching)
	# compare/contrast their results for vars vim, printenv vim, printenv BASH_FUNC_vim%%, and printenv | ack vim

	# TODO: it'd be nice if the query were implicitly over the variable NAMES, unless there's "something"
	# indicating a desire to search VALUES as well. (ex: equals sign in search query)
	local -a ignore_list
	# CAREFUL!!!! these values will be interpolated into a regex!
	# Specifically, .*THEME.* eats the ignore_ variables, because it matches itself in the value
	# TODO: it'd be nice to give these good names. Mostly thinking of this color regex
	ignore_list=(BASH_ALIASES LS_COLORS SDKMAN_CANDIDATES SDKMAN_CANDIDATES_CSV)
	ignore_list+=("sdkman_.+" "SCM_.+" "SDKMAN_.+" "THEME_.+" "BASH_IT_L(OAD|OG)_.+" "_.+(any underscore variables)*")
	ignore_list+=("[^=]+_THEME_.+")
	ignore_list+=("ignore_(list|regex)")
	ignore_list+=("(echo_|)(normal|reset_color|(background_|bold_|underline_|)(black|blue|cyan|green|orange|purple|red|white|yellow))")
	# Using IFS to join ignore_list with a single-character delimiter, from:
	# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string
	# TODO: printf?
	local ignore_regex ignore_filter
	ignore_regex=$(
		IFS='|'
		echo "${ignore_list[*]}"
	)
	printf -v ignore_filter '^(%s)=' "$ignore_regex"

	if [ "$#" -eq 0 ]; then
		# magic incantation from the internet
		# Basically, prints the variables and functions of
		# the current bash session, but doesn't print the functions
		( # TODO: `local -` instead of a subshell?
			set -o posix
			set
		) | grep -v -E "$ignore_filter" | pager
		echo "ignored ${ignore_list[*]}"
	else
		# nb: ack matching uses smartcase. Can't use grep here if we're using ack below
		if echo "$@" | ack "$ignore_regex" > /dev/null; then
			# we're looking for one of these variables. Don't filter.
			(
				set -o posix
				set
			) | ack "$@"
		else
			(
				set -o posix
				set
			) | ack -v "$ignore_filter" | ack "$@"
			# TODO: call out which (if any) of these matched. Potentially take args about it?
			# (but definitely don't do that last - our success/failure should be the one above)
			echo "ignored ${ignore_list[*]}"
		fi
	fi
}
alias var=vars # because I'm lazy

#function funs {
# TODO: Let's get a function-printing equivalent of vars
#}

function cdp {
	about "cd, but with an implicit mkdir -p"
	if ! test -d "${1?NEED A DIR}"; then
		# TODO: skip $1 if it's a flag, find the first non-flag
		echo creating "$1"
		mkdir -p "$1"
	fi
	cd "$@"
}

function _mr-isrepo-local {
	about "succeeds if the current folder is a git repo tracked by mr. fails otherwise"
	[[ -e .git ]] || return 1
	local status
	status="$(mr status)" || return 1

	[[ "x${status}" =~ status:.*\(in\ subdir\  ]] && return 1

	return 0
}

function _mr-isrepo {
	about "succeeds if the given folder is a git repo tracked by mr. fails otherwise"
	# TODO: "a git repo with a toplevel .mrconfig" trivially fits this definition. Also check that the .mrconfig is *external* to the git repo
	param '1: a folder which may or may not be an mr-tracked repo; default $PWD'
	(cd "${1-$PWD}" && _mr-isrepo-local) &> /dev/null
}

function _mr-able-single {
	about 'Within a single folder (default $PWD), if any child folder is tracked by mr, print every other child folder that *could* be tracked by mr'
	param '1: a single directory to check; default $PWD'
	local path="${1-$PWD}" candidate print_non_mr_repos printed
	local -a candidates non_mr_repos

	if [ ! -d "$path" ]; then
		echo "${path} - doesn't exist. No candidates analyzed"
		return
	fi

	# only the first-level child folders are candidates
	# TODO: `-d` is a bash 4.4-ism, and might not be supported in the rest of bash-it
	# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
	# NB: double < < is because <() produces a 'filename'-like argument
	# I'd like to call this `readarray` over mapfile, to not use the alias, but bash-it prefers mapfile
	mapfile -d '' candidates < <(find -L "$path" -maxdepth 1 -mindepth 1 -type d -not -name .git -print0 | sort -z)
	local candidate
	for candidate in "${candidates[@]}"; do
		if _mr-isrepo "$candidate"; then
			print_non_mr_repos="$candidate" # re-used below as the reason why we printed
			if [[ 0 -lt "${#non_mr_repos[@]}" ]]; then
				# Those ones previously that we didn't know if we needed to print?
				# Let's print them now!
				printf "%s\n" "${non_mr_repos[@]}"
				printed="yes, we printed output"
				non_mr_repos=()
			fi
		elif [ -n "$print_non_mr_repos" ]; then
			# We need to print it. Might as well print it now
			printf "%s\n" "$candidate"
			printed="yes, we printed output"
		else
			# Keep this one in case we need to print it later
			non_mr_repos+=("$candidate")
		fi
	done

	if [ -z "$printed" ]; then
		if [ -z "$print_non_mr_repos" ]; then
			printf "%s - no mr'd repositories within here (%d examined)\n" "$path" "${#candidates[@]}"
		else
			printf "%s - clean, with %d mr'd repositories and no non-mr'd repos\n" "$path" "${#candidates[@]}"
		fi
	else
		printf "%s - is an example mr'd repository\n" "$print_non_mr_repos"
	fi
}

function _mr-able-impl {
	# https://stackoverflow.com/questions/11655770/looping-through-the-elements-of-a-path-variable-in-bash, but I use printf to get the trailing colon
	local path
	while ifs=: read -d: -r path; do # `$ifs` is only set for the `read` command
		_mr-able-single "$path"
	done < <(printf "%s:" "$@")
	# NB: double indirection above is because `<()` is essentially a filename, not an indirection
}

function _mr-able {
	about 'for each path element in the argument (default $BASH_IT_PROJECT_PATHS) as a path varable, call out child folders that are not registered to mr, but are siblings with ones that are'
	param '*: Any number of $PATH-like folder lists to check. If none are given, $BASH_IT_PROJECT_PATHS is used implicitly'
	local -a args
	if [[ "$#" -eq 0 ]]; then
		args=("$BASH_IT_PROJECT_PATHS")
	else
		args=("$@")
	fi

	if [ -t 1 ]; then
		# Implicit jaketree output cleanup for stdout
		_mr-able-impl "${args[@]}" | jaketree
	else
		# Piping. Be cleaner
		_mr-able-impl "${args[@]}"
	fi
}

function cdgit {
	about 'cd into the git-dir for the current directory, or fail'
	local where
	where="$(git rev-parse --absolute-git-dir)" || return 1
	echo "found git dir at '${where}'. Going there"
	cd "$where"
}
alias gitcd=cdgit # not a typo - I literally don't know which name should be primary

function fidget {
	type fidget
	echo "TODO: loop this into jake-maintain-system tech"
	if [[ "$#" -eq 0 ]]; then
		echo "giving you a chance to cancel"
		sleep 12
	else
		echo "literally any argument works as-if it were '--quickly'"
	fi
	( # subshell. Automatically undoes the cd ~
		cd ~
		jake-sdkman-update
		pull # also does mr up, since ~/.mrconfig exists
		if _command_exists win-git-update &> /dev/null; then
			echo updating window git stuff too
			win-git-update
		fi
		apt-up
		if _command_exists winget.exe &> /dev/null; then
			echo "winget.exe exists - here's the update"
			winget.exe update
		fi
		_mr-able
	)
	echo "update completed at $(date)"
}
alias fid=fidget
alias f=fidget
alias ff="fidget --fast"
alias sdf=fidget
if ! _command_exists asdf; then
	# There's an asdf package manager
	alias asdf=fidget
fi

alias utc='date --utc'

alias jake-todo='ls-files | grep jake | j -x TODO'

function _jake-success {
	# Stash our success before a success from `local` or `about` overwrites it
	local success="$?"
	about 'succeeds if the prior command succeeds. Essentially an alias for [[ "$?" -eq 0 ]], aside from implementation details'
	[[ "$success" -eq 0 ]]
}

function vimfind {
	about "try to edit a bunch of files with fzf, using ack's -f file listing"
	FZF_DEFAULT_COMMAND='ack -f' fzf \
		--bind "enter:become(echo editing:; echo {+}; vim {+})" \
		--scheme=path \
		--multi \
		--reverse \
		--no-sort \
		--exit-0 \
		--select-1 \
		--header "Ctrl+Space to preview" \
		--bind "ctrl-space:execute(vim -q <(echo {}) </dev/tty >/dev/tty)" \
		--bind "ctrl-a:select-all" \
		--bind "ctrl-n:deselect-all" \
		--bind "q:abort" \
		--bind "change:unbind(q)" \
		--bind "backward-eof:rebind(q)" \
		--query "$@"
}
alias vimf=vimfind

# TODO: these *-whiches are becoming a pattern. Can this be a bash-it plugin, maybe using _jq-ify tech?
# TODO: they need completions
function vimwhich {
	# TODO: what if this were able to also jump to the source of a function or alias
	# We could try to use the (shopt -s extdebug; declare -F quote) tech to jump to functions
	# see https://askubuntu.com/questions/354915/quote-command-in-the-shell/354929#354929
	local where
	where="$(which "$1")"
	if _jake-success; then
		echo "success finding '$1' at '$where'"
		vim "$where"
	else
		echo "${FUNCNAME[0]} - ${1} is not found. Cannot open it for editing"
		# TODO: try vimfind instead
		return 1
	fi
}
alias vimw=vimwhich

function filewhich {
	# TODO: what if this was also able to call out that $1 is a function and/or alias, in addition to the executable it masks
	local where
	where="$(which "$1")"
	if _jake-success; then
		file "$where"
	else
		# Borrow file's error reporting... or potentially a successful fallback!
		file "$1"
	fi
}
alias filew=filewhich

function catwhich {
	# TODO: what if this was also able to print functions and aliases, too?
	# TODO: what if we follow aliases down to their roots?
	local where
	where="$(which "$1")"
	if _jake-success; then
		cat "$where"
		if [[ -t 1 ]]; then # stdout is terminal. Cool to add info (see jake's bin/git)
			echo "${FUNCNAME[0]}: this file lives at '$where'"
		fi
	else
		echo "${FUNCNAME[0]} - ${1} is not found. Cannot display its contents"
		return 1
	fi
}
alias catw=catwhich

function llwhich {
	local where
	where="$(which "$1")"
	if _jake-success; then
		ls -al "$where"
	else
		# Borrow ls's error reporting... or potentially a successful fallback!
		ls -al "$1"
	fi
}
alias llw=llwhich
alias lsw=llwhich

function cdwhich {
	about "technically, cddwhich - [cd] into the [d]irectory of [which] executable we're talking about"
	# TODO: what if this could move to the directory of the source of a function, too?
	if [[ "$#" -eq 0 ]]; then
		echo "${FUNCNAME[0]}: need an argument"
		return 1
	fi
	local where # needs a separate line, otherwise the failure of `which` could be eaten by the success of `local`
	where="$(which "$1")"
	if _jake-success; then
		cdd "$where"
	else
		# a deviation from cdd behavior - `cdd ""` is the 'silly goose, you cd'd into the parent directory of a current file!' case
		echo "${FUNCNAME[0]} - ${1} is not found. Cannot change to its parent directory"
		return 1
	fi
}
alias cddwhich=cdwhich
alias cddw=cdwhich
alias cdw=cdwhich

complete -c vimwhich filewhich catwhich llwhich cdwhich
#TODO: I'm manually invoking the complete-alias completions on some aliases here. This is not super maintainable. These functions should become
# their own plugin, so their aliases can just be handled by complete-alias and I can remove this line
complete -F _complete_alias vimw filew catw llw cddwhich cddw cdw

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
	if ! [[ -t 0 ]]; then
		# stdin not from terminal. assume it's xml
		args+=('-')
	fi

	# insufficient args. Reading from stdin *does* add to this count
	if [[ "${#args[@]}" -lt 2 ]]; then
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

function timing {
	about 'the `time` command, but also put timestamps in front of each printed line'
	# nb: ts is from moreutils
	time "$@" | ts -s
}
