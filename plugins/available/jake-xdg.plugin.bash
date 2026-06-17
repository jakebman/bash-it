# shellcheck shell=bash
cite about-plugin
about-plugin 'Set certain environment variables to make their corresponding apps play well with XDG-isms'
# BASH_IT_LOAD_PRIORITY: 125

## XDG_CONFIG_HOME
: ${XDG_CONFIG_HOME:=${HOME}/.config}

# Curl is documented to check for curlrc at $XDG_CONFIG_HOME/curlrc ONLY if XDG_CONFIG_HOME is set.
# I dislike this for four reasons:
# 1. It's wrong, because there's a bug. Use strace on curl 8.5.0 and you'll see it check $XDG_CONFIG_HOME/.curlrc instead:
#         $ XDG_CONFIG_HOME=/foo/bar strace curl |& grep foo/bar
#         openat(AT_FDCWD, "/foo/bar/.curlrc", O_RDONLY) = -1 ENOENT (No such file or directory)
# 2. It only works if XDG_CONFIG_HOME is set. You're supposed to use ~/.config if XDG_CONFIG_HOME is missing.
# 3. Item 2 is also a lie. Not sure if there's a bug in the docs, but Dec 6 2023 curl-8_5_0(7161cb17c) also tries to check $HOME/.config/.curlrc independently
# 4. (re: 2, despite 3) I won't be blackmailed into exporting XDG_CONFIG_HOME with its default value if I can help it
#         (Please ignore the git history which shows me doing exactly that here)
# That means I need intervention.
# I *want* curlrc to live at "${XDG_CONFIG_HOME}/curl/curlrc", but there's no way to do that in env variables
# So, I'm storing a symlink from "${XDG_CONFIG_HOME}/curl/.curlrc" to {the same, but without a dot} in my dotfiles repo
# And instead relying on curl to use its primary choice for curlrc: `1) "$CURL_HOME/.curlrc"`, per the manpage
export CURL_HOME="${XDG_CONFIG_HOME}/curl"
# lol - less *isn't* documented to require XDG_CONFIG_HOME to be set... but it won't find ${XDG_CONFIG_HOME:-~/.config}/lesskey if XDG_CONFIG_HOME isn't set
export LESSKEYIN="${XDG_CONFIG_HOME}/lesskey"
export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export PASSWORD_STORE_DIR="${XDG_CONFIG_HOME}/password-store" # `pass` command
# https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
# But, ~/.docker keeps getting created anyway on startup. Sigh.
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export RANCHER_CONFIG_DIR="${XDG_CONFIG_HOME}/rancher"
# I had to rip this from their source code: https://github.com/GitGuardian/ggshield/blob/8b6464d31be1cef6fa3f4ceec1fe9894a8454c27/ggshield/core/dirs.py#L16
export GG_USER_HOME_DIR="${XDG_CONFIG_HOME}/ggshield"
# This file might configure `cache=...`, which removes the need for $npm_config_cache variable, below
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

# TODO: it'd be nice to have this set BEFORE bash starts, but hey, that's what `bind -f` is for!
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
[ -f "$INPUTRC" ] && bind -f "$INPUTRC"


# *On Linux*, the *default backing store* respects the java.util.prefs.userRoot and java.util.prefs.systemRoot system properties
# per https://docs.oracle.com/en/java/javase/11/core/preferences-api1.html#GUID-2DAC3DD0-993A-41A8-8CDC-F8E3A72E1AE3__SECTION_KWW_Z1P_S3B
# (but, for ex., Windows uses the registry)
# Documented journey to find the appropriate ENV variable to convince all javas to use this system property:
# A Stack Overflow answer suggests _JAVA_OPTIONS: https://stackoverflow.com/a/8158708/285944
# ... it cites to a blog post and the Java2D spec for java 1.5, which aren't good canonical citations, but the docs for Java 8 do agree:
#     https://docs.oracle.com/javase/8/docs/technotes/guides/2d/flags.html
# I search for canonical docs for _JAVA_OPTIONS and find https://stackoverflow.com/questions/28327620/difference-between-java-options-java-tool-options-and-java-opts
#  The answer is that _JAVA_OPTIONS is for HotSport only. IBM has IBM_JAVA_OPTIONS, for ex.
#  https://bugs.openjdk.org/browse/JDK-4971166 suggests JAVA_TOOL_OPTIONS, which does seem to be documented:
#         https://docs.oracle.com/en/java/javase/11/troubleshoot/environment-variables-and-system-properties.html#GUID-BE6E7B7F-A4BE-45C0-9078-AA8A66754B97
# But there's also JDK_JAVA_OPTIONS: https://stackoverflow.com/questions/52986487/what-is-the-difference-between-jdk-java-options-and-java-tool-options-when-using
# Which is doc'd in java 21's man page:
#     Note: You can use the JDK_JAVA_OPTIONS launcher environment variable to prepend its content to the
#     actual command line of the java launcher [especially when launching a source-file java sh-bang file, but also in regular use(?)].
#     See Using the JDK_JAVA_OPTIONS Launcher Environment Variable.
# In the end, I followed https://dev.to/sunnybhambhani/different-environment-variables-available-in-java-101o - I'm choosing
# JAVA_TOOL_OPTIONS, which seems to be global, overridable, and I don't mind javac reading this too:
# Further justification: The JDK's debugging docs only know about JAVA_TOOL_OPTIONS, and don't mention JDK_JAVA_OPTIONS:
# https://docs.oracle.com/en/java/javase/23/troubleshoot/environment-variables-and-system-properties.html#GUID-A91E7E21-2E91-48C4-89A4-836A7C0EE93B
# https://docs.oracle.com/en/java/javase/23/troubleshoot/submit-bug-report.html#GUID-3933BFE1-0193-403E-8D72-2E0DC6639EE8
# Even more! AWS recommends this variable as well:
# https://docs.aws.amazon.com/sdkref/latest/guide/jvm-system-properties.html#:~:text=With%20an%20environment%20variable
# TODO: Some tools ref JAVA_OPTS, which is a conventional name for "args I'll add to my call to java (`java --my-args $JAVA_OPTS your.jar`)"
JAVA_TOOL_OPTIONS+=" -Djava.util.prefs.userRoot='${XDG_CONFIG_HOME}'/java"
export JAVA_TOOL_OPTIONS

## XDG_DATA_HOME
: "${XDG_DATA_HOME:=${HOME}/.local/share}"

export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
[ -d ~/.gradle ] && _log_warning "heads up - you have a dangling ~/.gradle folder. It lives in $GRADLE_USER_HOME now"
# TODO: --ivy flag here to also not create ~/.ivy2 folder; figure out how whitespace is supposed to work in this env var.
export SBT_OPTS="--sbt-dir ${XDG_DATA_HOME}/scala-build-tool"

# This is one of two default locations for the less history file, and I didn't like it at ~/.lesshst
# I could export XDG_DATA_HOME here instead of LESSHISTFILE, and less would implicitly use it.
# BUT I don't want to do that. See above about being blackmailed into exporting XDG vars to their default values.
export LESSHISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/lesshst"

## XDG_CACHE_HOME
: ${XDG_CACHE_HOME:=${HOME}/.cache}
# We export XDG_CACHE_HOME to its own value so that git-ignore-io from git-extras will respect it
# (it doesn't respect this folder unless this environment variable is defined, and there's no recourse)
export XDG_CACHE_HOME

# It's nice to have your $WGETRC include a `hsts-file = ~/.cache/wget/hsts` line.
# Unfortunately, wget 1) doesn't create the parent folder for this file, and
# 2) doesn't know how to interpolate environment variables from within that file so
# this value and that value may differ
if [ -f "$WGETRC" ]; then
	mkdir -p "${XDG_CACHE_HOME}/wget"
fi
# Ditto curl, with its cookie jar:
if grep -s -q "cookie-jar.*${XDG_CACHE_HOME}/curl" "$CURL_HOME/.curlrc" "$XDG_CONFIG_HOME/curlrc" "$HOME/.curlrc"; then
	# SPECULATIVE!!!
	# curlrc might contain a line like `--cookie-jar /home/jakebman/.cache/curl/cookie-jar`
	# (mine does)
	# I'd like to automatically create that file
	mkdir -p "${XDG_CACHE_HOME}/curl"
fi

# see `man npm` and https://docs.npmjs.com/cli/v10/commands/npm-cache
# We only need to set this cache directory if it's not in npmrc
# NB: because I don't always have/need an npmrc, this is the exact use case for grep -s
if ! grep -s -q ^cache= "$NPM_CONFIG_USERCONFIG"; then
	export npm_config_cache="${XDG_CACHE_HOME}/npm"
fi
export JARVIZ_DIR="${XDG_CACHE_HOME}" # a jar analyzer, from sdkman

# Apparently, Sonar Scanning decides to create ~/.sonar. The docs say I can redirect that
# https://docs.sonarsource.com/sonarqube-server/10.8/analyzing-source-code/analysis-parameters
export SONAR_USER_HOME="${XDG_CACHE_HOME}/sonarqube"

# .pyc files go here. Read more in `man python`'s entry on `-X pycache_prefix=PATH`
# Happily, it's automatically created, unlike the history file
export PYTHONPYCACHEPREFIX="${XDG_CACHE_HOME}/python/__pycache__"

## XDG_STATE_HOME
: ${XDG_STATE_HOME:=${HOME}/.local/state}

# TODO: python history: https://stackoverflow.com/questions/62063414/how-to-disable-python-history-saving
# or https://unix.stackexchange.com/questions/630642/change-location-of-python-history
# However, this canonical solution will be available in python 3.13:
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/python_history"
export REDISCLI_HISTFILE="${XDG_STATE_HOME}/redis/cli-history"
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/nodejs/cli-history"
# Thanks https://antonz.org/sqlite-history/
export SQLITE_HISTORY="${XDG_STATE_HOME}/sqlite/sqlite_history"
export PERL_CPANM_HOME="${XDG_STATE_HOME}/cpanm" # cpanm command in the cpanminus package from apt (for rakubrew)


# We create local folders to hold the history files, leaving a note that *I, Jake* created the folder, not the expected program
# Implemented via a bash-ish form of JS's IIFEs, so I can have local variables
# TODO: I'd like to be able to use this blurb for wget's hsts file too, but that doesn't follow this pattern. Refactor into two pieces: blurb, and blurb setup
function create_parent_folders_for {
	local name needed

	for name; do # implicit `in "$@"`
		local -n ref=$name # a nameref variable
		needed=$(dirname "$ref")

		# Only create the needed dir if it doesn't already exist.
		# That way, we don't claim credit if the folder already existed.
		if [[ ! -d "$needed" ]]; then
			_log_warning "Creating parent directory for custom, XDG-compatible \$${name} location at ${needed}"
			mkdir -p "$needed"
			cat <<-TABSTRIPPING_HEREDOC >"${needed}/.jake-autocreated-for-XDG-compatibility"
				This folder was auto-created by Jake's scripts (not the original program, which expects the parent folder to exist), to serve as a home for the ${name} file.
				I chose ${name} to be ./$(basename "$ref") to more closely match XDG behavior.
			TABSTRIPPING_HEREDOC
		fi
		unset -n ref # Needs `-n` to match `local` declaration above
	done
}

# [I]nvoke the [I]mmediate [F]unction [E]xpression
# These programs need their parent folder to exist:
create_parent_folders_for \
	PYTHON_HISTORY \
	SQLITE_HISTORY \
	NODE_REPL_HISTORY \
		&&
	unset -f create_parent_folders_for



# NB: there's no specific XDG_ env variable for this. Hence the obviously off-spec name
: ${JAKE_XDG_BIN_DIR:=${HOME}/.local/bin}
# install via https://github.com/pyenv/pyenv-installer. Installed via fork, so it's prudent to export it here
export PYENV_ROOT="${JAKE_XDG_BIN_DIR}/pyenv"
export GOPATH="${JAKE_XDG_BIN_DIR}/go"
# install via git clone 'git@github.com:cykerway/complete-alias.git' "$COMPLETE_ALIAS_DIR"
# for bash-it autocomplete; and for .mrconfig (which is why it must be exported)
export COMPLETE_ALIAS_DIR="${JAKE_XDG_BIN_DIR}/complete-alias"
export SDKMAN_DIR="${JAKE_XDG_BIN_DIR}/sdkman"

# ref https://askubuntu.com/questions/882562/how-can-i-change-or-hide-the-snap-directory
[ -d ~/snap ] && _log_warn 'consider hiding your ~/snap directory by running `sudo snap set system experimental.hidden-snap-folder=true`'

# XDG list:
# .aws - not configurable. The AWS_CONFIG_FILE and AWS_SHARED_CREDENTIALS_FILE can be configured, but not for instance .aws/cli/alias
#        doc: https://docs.aws.amazon.com/sdkref/latest/guide/file-location.html
#        NB: docker 'helpfully' overwrites my symlink with one into %USERPROFILE%
# .azure - symlinked into %USERPROFILE% by outside-WSL docker. Can probably remove it without damage.
# .bash - symlinked to .bashrc as tab-completion fodder to win over .bash{_history,_logout}
# .bashrc, .profile - requires decent high-powered intervention to loop in so early. Potentially an /etc/profile.d entry?
# .bash-it - inconvenient for me - it's easier to come in here and change stuff without it being a level deeper
# .cache, .config, ... .local - the XDG solution folders
# .editorconfig - currently not supported by all involved parties
# .gi_list - not supported. git-ignore-io in git-extras writes this
# .gitignore.d - vcsh, created by default. hardcoded name below $VCSH_BASE, which defaults to $HOME
# .gitmodules - required because I'm keeping subrepos in my conf vcsh repo
#     It needs to live in $GIT_WORK_TREE - gets really interesting with nns-config also having these
# .ispell_default - used by something in the spell/aspell/ispell/etc. family
# .ivy2 - sbt (scala build tool)'s equivalent to .m2
#     Potentialy configurable like java above, via:
#         https://www.scala-sbt.org/1.x/docs/Library-Management.html#Ivy+Home+Directory
#         https://stackoverflow.com/questions/3142856/how-to-configure-ivy-cache-directory-per-user-or-system-wide
#         https://www.scala-sbt.org/1.x/docs/Launcher-Configuration.html
#     Or simpler in the discussion of SBT_OPTS, above
# .kube - configurable via KUBECONFIG? (a $PATH-like variable, to list places to check)
# .landscape - ubuntu-ism
# .m2 - a symlink. Would otherwise require CLI argument to move settings.xml, which is the only thing I keep there anyway :(
#     TODO: maven 3.9.0+ accept CLI arguments via $MAVEN_ARGS. See https://maven.apache.org/configure.html
#     TODO: even lower mavens might also be viable to accept -D args via JAVA_TOOL_OPTIONS
#     TODO: alas, I have forgotten which CLI arguments would do this
# .motd_shown - probably not doable
# .mrconfig (& .mr which symlinks to beat .mrtrust at tab completion) - cannot be moved without a code change in mr tool
# .netrc - conventional file name, from telnet. Location configurable in curl, but not telnet.
# .npm - potentially configurable via `npm config set cache ~/...` or better. In Progress.
# .postman - paltry documentation. Not sure.
# .python_history - not currently configurable - will in 3.13
# .rakubrew, .raku - not worth changing right now. Still TODO
# .ssh - Not generally possible
# .sudo_as_admin_successful - SUPER(user) unlikely
# .vim - a symlink into .config/vim, for a small win. Removing this symlink requires rewriting vim to read an env. var
#        Update: "From [version 9.1.0327,] Vim looks for $XDG_CONFIG_HOME/vim/vimrc on its own, no further hacks required." https://jorenar.com/blog/vim-xdg
#        Link also has a workaround with VIMINIT (which interferes with my vim autoresume trick, for some reason)
# .wajig - Wajig is particularly unhelpful with its docs. Doesn't appear to respect XDG, so needs a symlink
# .zef - requires env variable, and the file the env var points to also needs to reference the new location
#
# snap - this directory without a dot is also polluting. Created by snapd. Supposedly configurable - read ablove
