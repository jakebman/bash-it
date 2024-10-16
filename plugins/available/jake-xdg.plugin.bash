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

## XDG_DATA_HOME
: "${XDG_DATA_HOME:-${HOME}/.local/share}"

export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
[ -d ~/.gradle ] && _log_warning "heads up - you have a dangling ~/.gradle folder. It lives in $GRADLE_USER_HOME now"

## XDG_CACHE_HOME
: ${XDG_CACHE_HOME:=${HOME}/.cache}

export JARVIZ_DIR="${XDG_CACHE_HOME}" # a jar analyzer, from sdkman

## XDG_STATE_HOME
: ${XDG_STATE_HOME:=${HOME}/.local/state}

export PERL_CPANM_HOME="${XDG_STATE_HOME}/cpanm" # cpanm command in the cpanminus package from apt (for rakubrew)

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
