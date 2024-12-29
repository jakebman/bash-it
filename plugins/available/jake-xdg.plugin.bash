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
# 2. It only works if XDG_CONFIG_HOME is set
# 3. Item 2 is also a lie. Not sure if there's a bug in the docs, but Dec 6 2023 curl-8_5_0(7161cb17c) also tries to check $HOME/.config/.curlrc independently
# 4. (re: 2, despite 3) I won't be blackmailed into exporting XDG_CONFIG_HOME with its default value
#         (Please ignore the git history which shows me doing exactly that here)
# That means I need intervention.
# I *want* curlrc to live at "${XDG_CONFIG_HOME}/curl/curlrc", but there's no way to do that in env variables
# So, I'm storing a symlink from "${XDG_CONFIG_HOME}/curl/.curlrc" to {the same, but without a dot} in my dotfiles repo
export CURL_HOME="${XDG_CONFIG_HOME}/curl"
export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
# https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export RANCHER_CONFIG_DIR="${XDG_CONFIG_HOME}/rancher"

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
# In the end, I followed https://dev.to/sunnybhambhani/different-environment-variables-available-in-java-101o - I'm choosing
# JAVA_TOOL_OPTIONS, which seems to be global, overridable, and I don't mind javac reading this too:
# Further justification: The JDK's debugging docs only know about JAVA_TOOL_OPTIONS, and don't mention JDK_JAVA_OPTIONS:
# https://docs.oracle.com/en/java/javase/23/troubleshoot/environment-variables-and-system-properties.html#GUID-A91E7E21-2E91-48C4-89A4-836A7C0EE93B
# https://docs.oracle.com/en/java/javase/23/troubleshoot/submit-bug-report.html#GUID-3933BFE1-0193-403E-8D72-2E0DC6639EE8
JAVA_TOOL_OPTIONS+=" -Djava.util.prefs.userRoot='${XDG_CONFIG_HOME}'/java"
export JAVA_TOOL_OPTIONS

## XDG_DATA_HOME
: "${XDG_DATA_HOME:=${HOME}/.local/share}"

export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
[ -d ~/.gradle ] && _log_warning "heads up - you have a dangling ~/.gradle folder. It lives in $GRADLE_USER_HOME now"
# TODO: --ivy flag here to also not create ~/.ivy2 folder; figure out how whitespace is supposed to work in this env var.
export SBT_OPTS="--sbt-dir ${XDG_DATA_HOME}/scala-build-tool"

## XDG_CACHE_HOME
: ${XDG_CACHE_HOME:=${HOME}/.cache}
# We export XDG_CACHE_HOME to its own value so that git-ignore-io from git-extras will respect it
# (it doesn't respect this folder unless this environment variable is defined)
export XDG_CACHE_HOME

# It's nice to have your $WGETRC include a `hsts-file = ~/.cache/wget/hsts` line.
# Unfortunately, wget 1) doesn't create the parent folder for this file, and
# 2) doesn't know how to interpolate environment variables from within that file so
# this value and that value may differ
if [ -f "$WGETRC" ]; then
	mkdir -p "${XDG_CACHE_HOME}/wget"
fi

# see `man npm` and https://docs.npmjs.com/cli/v10/commands/npm-cache
export npm_config_cache="${XDG_CACHE_HOME}/npm"
export JARVIZ_DIR="${XDG_CACHE_HOME}" # a jar analyzer, from sdkman

## XDG_STATE_HOME
: ${XDG_STATE_HOME:=${HOME}/.local/state}

# TODO: python history: https://stackoverflow.com/questions/62063414/how-to-disable-python-history-saving
# or https://unix.stackexchange.com/questions/630642/change-location-of-python-history
# However, this canonical solution will be available in python 3.13:
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/python_history"
export REDISCLI_HISTFILE="${XDG_STATE_HOME}/redis/cli-history"
export SQLITE_HISTORY="${XDG_STATE_HOME}/sqlite/cli-history"
export PERL_CPANM_HOME="${XDG_STATE_HOME}/cpanm" # cpanm command in the cpanminus package from apt (for rakubrew)

# These programs need their parent folder to exist:
mkdir -p "$(dirname "$PYTHON_HISTORY")"
mkdir -p "$(dirname "$SQLITE_HISTORY")"

: ${JAKE_XDG_BIN_DIR:=${HOME}/.local/bin}
# install via https://github.com/pyenv/pyenv-installer. Installed via fork, so it's prudent to export it here
export PYENV_ROOT="${JAKE_XDG_BIN_DIR}/pyenv"
export GOPATH="${JAKE_XDG_BIN_DIR}/go"
# install via git clone 'git@github.com:cykerway/complete-alias.git' "$COMPLETE_ALIAS_DIR"
# for bash-it autocomplete; and for .mrconfig (which is why it must be exported)
export COMPLETE_ALIAS_DIR="${JAKE_XDG_BIN_DIR}/complete-alias"

# XDG list:
# .aws - not configurable. The AWS_CONFIG_FILE and AWS_SHARED_CREDENTIALS_FILE can be configured, but not for instance .aws/cli/alias
# .azure - symlinked into $WSL_WINDOWS_USER_HOME. Can probably remove it without damage.
# .bash - symlinked to .bashrc as tab-completion fodder to win over .bash{_history,_logout}
# .bashrc, .profile - requires decent high-powered intervention to loop in so early. Potentially an /etc/profile.d entry?
# .bash-it - inconvenient for me - it's easier to come in here and change stuff without it being a level deeper
# .cache, .config, ... .local - the XDG solution folders
# .colordiffrc - not configurable. Could overwrite /etc/colordiffrc to do the same, but... that's not nice
# .editorconfig - currently not supported by all involved parties
# .gi_list - not supported. git-ignore-io in git-extras writes this
# .gitguardian.yaml - not supported. ggshield only wants files in ~.
#     See find_global_config_path/get_global_path/USER_CONFIG_FILENAMES in https://github.com/GitGuardian/ggshield/blob/6d0d8b86c504e0066de5758c69d8cd95a4f09426/ggshield/core/constants.py#L19
# .gitignore.d - vcsh, created by default. hardcoded name below $VCSH_BASE, which defaults to $HOME
# .gitmodules - required because I'm keeping subrepos in my conf vcsh repo
#     It needs to live in $GIT_WORK_TREE - gets really interesting with nns-config also having these
# .inputrc - conventional file name, from readline. Used by bash, and anything else using that library. Library respects $INPUTRC. Are we too late to change it during .bashrc loading?
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
# .motd_shown - probably not doable
# .mrconfig (& .mr which symlinks to beat .mrtrust at tab completion) - cannot be moved without a code change in mr tool
# .netrc - conventional file name, from telnet. Location configurable in curl, but not telnet.
# .npm - potentially configurable via `npm config set cache ~/...` or better. In Progress.
# .postman - paltry documentation. Not sure.
# .python_history - not currently configurable - will in 3.13
# .rakubrew, .raku - not worth changing right now. Still TODO
# .sdkman - inconvenient for me, same as .bash-it
# .ssh - Not generally possible
# .sudo_as_admin_successful - SUPER(user) unlikely
# .vim - a symlink into .config/vim, for a small win. Removing this symlink requires rewriting vim to read an env. var
# .zef - requires env variable, and the file the env var points to also needs to reference the new location
