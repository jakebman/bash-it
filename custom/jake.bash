# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export BASH_IT_CURL_PAGER='bat --style=numbers'
export MANPAGER="less --lesskey-src '${HOME}/.config/lesskey-no-gotoend-on-q'"
export WATCH_INTERVAL=1.2 # I'm a little impatient. It's nice to have this be a little faster than the full 2s

# This could be accomplished by KUBECONFIG+="${KUBECONFIG+:}${XDG_CONFIG_HOME:-${HOME}/.config}/kubectl/config",
# but that's much less readable.
# TODO: a generic pathmunge that could be used here
if [ -v KUBECONFIG ]; then
	KUBECONFIG+=":"
fi
KUBECONFIG+="${XDG_CONFIG_HOME:-${HOME}/.config}/kubectl/config"
if [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/jake/windows-user-home" ]; then
	KUBECONFIG+=":"
	KUBECONFIG+="${XDG_CONFIG_HOME:-${HOME}/.config}/jake/windows-user-home/.kube/config"
fi
export KUBECONFIG

# A custom flag, respected by my custom kubectl, which respects some flags. Check the source for full listing
# Thanks to https://github.com/kubernetes/kubectl/issues/1154 for the naming convention
# unsure if any parents need to be created
export KUBECTL_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/kubectl"

# (TODO: this probably doesn't always work. Didn't for gradle at least)
# Enable java to read the cacertificates from linux. Technically, there's an intermediate process (ca-certificates-java)
# that copies to here, but it's close enough to update-ca-certificates that you only need to know this if you're getting
# errors
JAVA_TOOL_OPTIONS+=" -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
export JAVA_TOOL_OPTIONS

# The python library `webbrowser` has some weird hiccups. Setting this environment variable
# allows the aws cli and my ~/bin/splunk tool to avoid experiencing an `tcgetpgrp failed: Not a tty` error
# (I no longer need to set AWS_BROWSER, as it defaults to BROWSER)
export BROWSER=wslview

_BASH_IT_AWS_AUTOLOGIN_EXCEPTIONS+=(login loggedin logout)

# Programs that can only be run by sudo. Putting an implicit ahead of it seems fine
alias iotop='sudo iotop'
alias iftop='sudo iftop'

# Allow j!! to work for a previous ack query
alias jack=j
# I want j!! to work for a previous pj query, too
alias jpj=j

# Alias to look for my files
alias jake='j --jake'

alias cnn='browse http://cnn.com'

# TODO: can I get autocomplete on a single tab?

# requires maven 3.9+ https://maven.apache.org/configure.html#maven_args-environment-variable
export MAVEN_ARGS="-T1C"

# Get timing output in maven. Doesn't require maven >= 3.9 (sets java system properties, not maven switches)
MAVEN_OPTS+=" -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss.SSS"
export MAVEN_OPTS

if [ -v LESS ]; then
	_log_warning "LESS has a value before I start adding my custom flags. Resetting it to '' from [$LESS]"
	# We will follow a trailing space pattern.
	# That permits `LESS+=--a-single-new-flag some command` invocations, and allows better inline comments below
	LESS=''
fi

# quit-if-one-screen allows less to simply dump the output to STDOUT when it would all fit on a single page
#   see https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
LESS+="--quit-if-one-screen "
LESS_ABBREV+=F
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
LESS+="--quit-at-eof "
LESS_ABBREV+=e
# no-init disables that weird 'second screen' behavior, which I don't like
LESS+="--no-init "
LESS_ABBREV+=X
# ignore-case is actually smartcase - all-lowercase is case-insensitive; add an uppercase to require case matching
LESS+="--ignore-case "
LESS_ABBREV+=i
# RAW-CONTROL-CHARS enables color interpretation without allowing every raw control code through
#   (b/c that would make lines hard to track)
LESS+="--RAW-CONTROL-CHARS "
LESS_ABBREV+=R
# tabs=2 condenses tabs to only two characters wide
LESS+="--tabs=2 "
LESS_ABBREV+=x2
# jump-target=.2 puts the searched-for line 2/10ths of the way down the screen, rather than at the top line
#   (Heads up! 0.2 does not work. I tried, and learned that)
#   This also applies to 'go to line' and 'go to tag' commands
LESS+="--jump-target=.2 "
LESS_ABBREV+=j.2
# SEARCH-SKIP-SCREEN ensures that new searches start below the jump-target line, and not the top of the screen
#   Repeated searches (with n/N) already did this, but if you search for something new
#        you would otherwise be searching 2/10ths of the screen *up* from where you started
#   It's also worth noting that this is *per line*, so following matches on the same line are also skipped
LESS+="--SEARCH-SKIP-SCREEN "
# LESS_ABBREV+=A # Not available in less version 436 on rhel
# use-color gets a nice light cyan color on some of less's UI elements
LESS+="--use-color "
# LESS_ABBREV+=" --use-c" # Not available in less version 436 on rhel
# follow-name ensures that `less +F /var/log/foo` emulates `tail -F`, not `tail -f`. i.e. an implicit --follow=name
LESS+="--follow-name "
LESS_ABBREV+=" --fol"
# There's some cool discussion on the value of these flags used in SYSTEMD_LESS in the `man systemctl` docs
export LESS LESS_ABBREV
export SYSTEMD_LESS=$LESS # `systemctl` overwrites my $LESS by default. This is how to prevent that

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

alias find-ack='ack -f'
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
		if [ -t 1 ]; then
			>&2 echo "(This command takes a long time, and it's eating apt-file's progress bar. Sorry.)"
		fi
		(dpkg -L "$@" || apt-file list "$@") | pager
	fi
}

function vars {
	# TODO: this is both better and worse than printenv (printenv recognizes functions, but doesn't do partial matching)
	# compare/contrast their results for vars vim, printenv vim, printenv BASH_FUNC_vim%%, and printenv | ack vim

	# TODO: it'd be nice if the query were implicitly over the variable NAMES, unless there's "something"
	# indicating a desire to search VALUES as well. (ex: equals sign in search query)
	local -a ignore_keys
	# CAREFUL!!!! these values will be interpolated into a larger regex to try and match only the key part
	# If your regex can eat an equals sign, you might end up matching a value
	# (That's why {prefix}_THEME_{suffix} specifically excludes equal signs, otherwise it also grabs ignore_keys=..._THEME_...
	# TODO: it'd be nice to give these good names beyond the dumb regex comment. Mostly thinking of this color regex
	ignore_keys+=(BASH_ALIASES LS_COLORS SDKMAN_CANDIDATES SDKMAN_CANDIDATES_CSV)
	ignore_keys+=("sdkman_.*" "SCM_.*" "SDKMAN_.*" "THEME_.*" "BASH_IT_(LOAD|LOG)_.*" "_.+(any underscore variables)*")
	ignore_keys+=("[^=]+_THEME_.*")
	ignore_keys+=("ignore_(keys|key_regex|regex)")
	ignore_keys+=("(echo_|)(normal|reset_color|(background_|bold_|underline_|)(black|blue|cyan|green|orange|purple|red|white|yellow))")
	# Using IFS to join ignore_keys with a single-character delimiter, from:
	# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string
	local ignore_key_regex ignore_regex
	ignore_key_regex=$(
		IFS='|'
		echo "${ignore_keys[*]}"
	)
	printf -v ignore_regex '^(%s)=' "$ignore_key_regex"

	# Specifically ignore the bash command, if possible. (The quoting is hard, man. TODO.)
	ignore_regex+="|^BASH_COMMAND='vars ${1}'$"

	if [ "$#" -eq 0 ]; then
		# magic incantation from the internet
		# Basically, prints the variables and functions of
		# the current bash session, but doesn't print the functions
		( # TODO: `local -` instead of a subshell?
			set -o posix
			set
		) | grep -v -E "$ignore_regex" | pager

		echo
		echo "# Ignored ${ignore_keys[*]} and BASH_COMMAND (if literal match)"
	else
		# nb: ack matching uses smartcase. Can't use grep here if we're using ack below
		# TODO: it's hacky to try and match our regex to the user input. The correct math is:
		# Filter all vars to the ignored keys onto lines then check if `ack "$@"` matches any of those lines
		if echo "$@" | ack "${ignore_key_regex}|BASH_COMMAND" > /dev/null; then
			# we're looking for one of these variables. Don't filter.
			# TODO: this also searches the values of other ignored variables we didn't request. Can be explosive
			(
				set -o posix
				set
			) | ack "$@"
		else
			(
				set -o posix
				set
			) | ack -v "$ignore_regex" | ack "$@"
			# TODO: call out which (if any) of these matched. Potentially take args about it?
			# (but definitely don't do that last - our success/failure should be the one above)

			echo
			echo "# Ignored ${ignore_keys[*]} and BASH_COMMAND (if literal match)"
		fi
	fi
}
alias var=vars # because I'm lazy

#function funs {
# TODO: Let's get a function-printing equivalent of vars
#}

function path_to_lines {
	if [ 0 -ne "$#" ]; then
		# have args - apply to them
		local arg
		for arg; do
			if [ -v "$arg" ]; then # user specified a variable name
				echo "### $arg is..."
				arg="${!arg}"
			fi
			echo "$arg"
		done
	elif [ -t 0 ]; then
		# stdin is a terminal. Apply to $PATH
		echo "$PATH"
	else
		# stdin is a pipe - apply to everything
		cat
	fi |
		tr ':' "\n"
}

function edit-base64-as-file {
	local temp
	temp=$(mktemp editing-base64-as-file-XXXXXXXXXX --tmpdir)

	echo -e "\n\n\n"

	base64 -d <<< "$1" >"$temp"
	"${EDITOR-edit}" "$temp"
	base64 --wrap 0 "$temp"

	echo -e "\n\n\n"
	echo "# The output file is ${temp}. Use base64 --wrap 0 ${temp} to get the encoded output again"
}

function cdp {
	about "cd, but with an implicit mkdir -p"
	if ! test -d "${1?NEED A DIR}"; then
		# TODO: skip $1 if it's a flag, find the first non-flag
		echo creating "$1"
		mkdir -p "$1"
	fi
	cd "$@"
}

unalias c # defined in general aliases
function c {
	about 'a typo of cd that can be spelled `c d $yourArg`, or just `c $yourArg`'
	if [[ "$#" -gt 0 ]] && [[ d = "$1" ]]; then
		shift
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
	mapfile -t -d '' candidates < <(find -L "$path" -maxdepth 1 -mindepth 1 -type d -not -name .git -print0 | sort -z)
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
	# TODO: there is also cd-git in jake-cd-git-root
	about 'cd into the root of a git repo/worktree for the current directory, or fail'
	local where how

	if where="$(git rev-parse --show-toplevel 2>/dev/null)"; then
		# NB: This also respects GIT_WORK_TREE
		how="- the toplevel from rev-parse"
	elif [ 'true' = "$(git rev-parse --is-inside-git-dir)" ]; then
		# https://stackoverflow.com/questions/12293944/how-to-find-the-path-of-the-local-git-repository-when-i-am-possibly-in-a-subdire/12293994#12293994
		where="$(git rev-parse --git-dir)/.." || return 1
		how="- the parent of the .git dir we're in"
	else
		>&2 echo "${FUNCNAME}: Unable to find toplevel folder of this git repo. (Do we have one?)"
		return 1
	fi
	echo "found git dir at '${where}' ${how}. Going there"
	cd "$where"
}
alias gitcd=cdgit # not a typo - I literally don't know which name should be primary

function cdmaven {
	about 'cd into your maven repository, using a gav as-if it were a folder name'
	param '1: an artifact-like gav. "com.twc.mystro.mas.integration:mas-integration:pom:5.4.6-SNAPSHOT"'
	local gav="${1?need an arg}"

	# TODO: classifier can appear before version, like in example above.
	local group artifact classifier version
	IFS=: read group artifact classifier version <<< "$gav"
	: ${version:=$classifier} # grab version from classifier if it's missing or empty

	vars | grep -E 'group|artifact|version|classifier'

	local dest="${group//[.]//}/${artifact}/${version}"


	echo "going to ${dest}"

	cd ~/.m2/repository/"${dest}"
}
alias mavencd=cdmaven # ditto cdgit above
alias cdr=cdmaven     # r for 'repository'

function _fidget_options {
	local arg
	local OPTIND=1 # Reset OPTIND for this function, so getopts starts at $1, not $ummm....?
	while getopts 'afqh' arg; do
		case "$arg" in
			a)
				UPDATE_JUNK_DRAWER=true
				;;
			f|q)
				fast="Not waiting to cancel"
				;;
			*)
				fast='Any unrecognized argument is interpreted as if it were -f/-q for fast or quick running'
				;;
		esac
	done
}

function fidget {
	type fidget | bat --language bash --style=plain --paging=never
	echo "TODO: loop this into jake-maintain-system tech"

	# set by _fidget_options. UPDATE_JUNK_DRAWER needs to be exported to mr up, invoked from `pull`
	local fast
	local -x UPDATE_JUNK_DRAWER
	_fidget_options "$@"

	[ -n "$UPDATE_JUNK_DRAWER" ] && echo "Including Junk Drawer in update"

	if [[ -n "$fast" ]]; then
		echo "$fast"
	else
		echo "Giving you a chance to cancel"
		sleep 12
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
alias ff="fidget -f" # --fast
alias ffa="fidget -fa"
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

# TODO: permit flags by essentially "for each flag, if it's `which`-able, replace the word with its location"
# TODO: permit multiple arguments
function _outwhich {
	# TODO: what if this was also able to print functions and aliases, too?
	# TODO: what if we follow aliases down to their roots?
	local command=$1
	shift
	local where
	where="$(which "$1")"
	if _jake-success; then
		"$command" "$where"
		if [[ -t 1 ]]; then # stdout is terminal. Cool to add info (see jake's bin/git)
			echo "${command}which: this file lives at '$where'"
		fi
	else
		echo "${command}which - ${1} is not found. Cannot display its contents"
		return 1
	fi
}
alias catwhich='_outwhich cat'
alias catw=catwhich
alias headwhich='_outwhich head'
alias headw=headwhich
alias tailwhich='_outwhich tail'
alias tailw=tailwhich

function stringswhich {
	local where
	where="$(which "$1")"
	if _jake-success; then
		(
			strings "$where"
			if [[ -t 1 ]]; then # stdout is terminal. Cool to add info (see jake's bin/git)
				echo "${FUNCNAME[0]}: this file lives at '$where'"
			fi
		) | pager
	else
		echo "${FUNCNAME[0]} - ${1} is not found. Cannot display its contents"
		return 1
	fi
}
alias stringsw=stringswhich

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

complete -c \
	{head,cat,tail}which \
	_outwhich \
	vimwhich \
	filewhich \
	stringswhich \
	llwhich \
	cdwhich
#TODO: I'm manually invoking the complete-alias completions on some aliases here. This is not super maintainable. These functions should become
# their own plugin, so their aliases can just be handled by complete-alias and I can remove this line
complete -F _complete_alias \
	catw \
	vimw \
	filew \
	stringsw \
	llw \
	cddwhich \
	cddw \
	cdw

function xml {
	if [[ "$#" -eq 0 ]] && [[ -t 0 ]]; then
		# reading from terminal, but no arguments on the CLI
		echo "insufficient arguments (this command doesn't take an implicit stdin well :( )"
		echo "usage: ${FUNCNAME[0]} <file>..."
		return 1
	fi

	# XMLLINT_INDENT is for xmllint. It can take arbitrary strings ("I am an indent string   "), which we can't emulate here
	# so we just grab its length if it is defined, defaulting to 2 spaces
	local indent=${XMLLINT_INDENT+${#XMLLINT_INDENT}}
	: ${indent:=2}
	# -f forces newlines between elements w/o children
	# -nbe suppresses newline before end-tag
	xmlindent -i "$indent" -f -nbe "$@" | bat --language xml
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

	# Grab xpath arg, leaving filenames
	local xpath=$1
	shift

	# Default namespaces confuse the hell out of xpath.
	# See: https://stackoverflow.com/questions/28473291/force-xmllint-to-ignore-bad-default-xmlns
	# TODO: this could potentially be smarter for multiple files, instead of cat-ing them all together
	# TODO: this fix should call out that it applied, to stderr. This is a very "I had an error" situation
	#
	# On the tail end, we pass the output through the `xml` formatter, defined above
	# because xmllint --format --xpath feels like it puts each result on a new line or something else weird.
	# But that's fine, because that's what `xml`'s job *is*
	xml "$@" | # proper formatting, so sed is more likely to catch
		sed --regexp-extended 's/\bxmlns="[^"]*"//g' | # strip default namespace
		xmllint --xpath "$xpath" - | # The actual work we came here for
		xml # final coloring, paging, etc
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
