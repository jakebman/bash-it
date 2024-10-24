# shellcheck shell=bash
cite about-plugin
about-plugin 'Set certain environment variables to make their corresponding apps play well with XDG-isms'
# BASH_IT_LOAD_PRIORITY: 125

## XDG_CONFIG_HOME
: ${XDG_CONFIG_HOME:=${HOME}/.config}

# We export XDG_CONFIG_HOME to its own value so that curl will respect it
# (curl doesn't respect this folder unless this environment variable is defined)
export XDG_CONFIG_HOME
export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
# https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export RANCHER_CONFIG_DIR="${XDG_CONFIG_HOME}/rancher"

# *On Linux*, the *default backing store* respects this system property,
# per https://docs.oracle.com/en/java/javase/11/core/preferences-api1.html#GUID-2DAC3DD0-993A-41A8-8CDC-F8E3A72E1AE3__SECTION_KWW_Z1P_S3B
# (but, for ex., Windows uses the registry)
alias jshell='jshell -J-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME}/java"'

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

export JARVIZ_DIR="${XDG_CACHE_HOME}" # a jar analyzer, from sdkman

## XDG_STATE_HOME
: ${XDG_STATE_HOME:=${HOME}/.local/state}

# TODO: python history: https://stackoverflow.com/questions/62063414/how-to-disable-python-history-saving
# or https://unix.stackexchange.com/questions/630642/change-location-of-python-history
export REDISCLI_HISTFILE="${XDG_STATE_HOME}/redis/cli-history"
export PERL_CPANM_HOME="${XDG_STATE_HOME}/cpanm" # cpanm command in the cpanminus package from apt (for rakubrew)
alias wget='wget --hsts-file="${XDG_STATE_HOME}/wget-hsts"'

: ${JAKE_XDG_BIN_DIR:=${HOME}/.local/bin}
# install via https://github.com/pyenv/pyenv-installer. Installed via fork, so it's prudent to export it here
export PYENV_ROOT="${JAKE_XDG_BIN_DIR}/pyenv"
export GOPATH="${JAKE_XDG_BIN_DIR}/go"
# install via git clone 'git@github.com:cykerway/complete-alias.git' "$COMPLETE_ALIAS_DIR"
# for bash-it autocomplete; and for .mrconfig (which is why it must be exported)
export COMPLETE_ALIAS_DIR="${JAKE_XDG_BIN_DIR}/complete-alias"

# XDG list:
# .aws - not configurable
# .azure - symlinked into $WSL_WINDOWS_USER_HOME. Can probably remove it without damage.
# .bash - symlinked to .bashrc as tab-completion fodder to win over .bash{_history,_logout}
# .bashrc, .profile - requires decent high-powered intervention to loop in so early. Potentially an /etc/profile.d entry?
# .bash-it - inconvenient for me - it's easier to come in here and change stuff without it being a level deeper
# .cache, .config, ... .local - the XDG solution folders
# .editorconfig - currently not supported by all involved parties
# .gi_list - not supported. git-ignore-io in git-extras writes this
# .gitignore.d - vcsh, created by default. hardcoded name below $VCSH_BASE, which defaults to $HOME
# .gitmodules - required because I'm keeping subrepos in my conf vcsh repo
#    It needs to live in $GIT_WORK_TREE - gets really interesting with nns-config also having these
# .java - for jshell, and other users of the jdk's java.util.prefs.Preferences API
# .landscape - ubuntu-ism
# .m2 - a symlink. Would otherwise require CLI argument to move settings.xml, which is the only thing I keep there anyway :(
# .motd_shown - probably not doable
# .mrconfig (& .mr which symlinks to beat .mrtrust at tab completion) - cannot be moved without a code change in mr tool
# .netrc - conventional file name, from telnet. Location configurable in curl, but not telnet.
# .python_history - not currently configurable
# .rakubrew, .raku - not worth changing right now. Still TODO
# .sdkman - inconvenient for me, same as .bash-it
# .ssh - Not generally possible
# .sudo_as_admin_successful - SUPER(user) unlikely
# .vim - a symlink into .config/vim, for a small win. Removing this symlink requires rewriting vim to read an env. var
# .wget-hsts - inconvenient to change (only via cli argument, or by creating an unmovable .wgetrc file in the same place)
# .zef - requires env variable, and the file the env var points to also needs to reference the new location
