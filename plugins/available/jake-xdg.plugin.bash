#!/usr/bin/env bash

# I want my .curlrc file in ~/.config, which is the default XDG_CONFIG_HOME
# But curl doesn't recognize that properly, so I define it to its default
# value here
: ${XDG_CONFIG_HOME:=${HOME}/.config}
export XDG_CONFIG_HOME
export ACKRC="${XDG_CONFIG_HOME}/ack/ackrc"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
# https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# Gradle is the only current user of XDG_DATA_HOME, so it's inlined here
export GRADLE_USER_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/gradle"

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

# for bash-it autocomplete; and for .mrconfig (which is why it must be exported)
export COMPLETE_ALIAS_DIR="${HOME}/.local/bin/complete-alias"

# Defined here to parallel above, and to be explicit for the next few lines
# No need to export it because I don't know of any programs that need this defined to work
: ${XDG_STATE_HOME:=${HOME}/.local/state}

[ -d ~/.gradle ] && echo "heads up - you have a dangling ~/.gradle folder. It lives in $GRADLE_USER_HOME now"

export PERL_CPANM_HOME="${XDG_STATE_HOME}/cpanm" # cpanm command in the cpanminus package from apt (for rakubrew)
# These next few lines are verbatim from history-eternal plugin. I want 'something' like this, in order to automatically
# create the XDG directory for $HISTFILE. And *this code* is very much something like itself.
# WARNING TVTROPES LINK: https://tvtropes.org/pmwiki/pmwiki.php/Main/ShapedLikeItself
HISTDIR="${XDG_STATE_HOME:-${HOME?}/.local/state}/bash"
[[ -d ${HISTDIR?} ]] || mkdir -p "${HISTDIR?}"
readonly HISTFILE="${HISTDIR?}/history" 2>/dev/null || true

# Grab old HISTFILE, if it exists, and seems newer than the new HISTFILE
if [[ ~/.bash_history -nt "$HISTFILE" ]]; then
  # -nt is false on missing first files, true on missing second files
  mv ~/.bash_history "$HISTFILE"
  touch ~/.bash_history-moved-to-XDG-because-jake-custom-bash-it
fi

: ${XDG_CACHE_HOME:=${HOME}/.cache}
export JARVIZ_DIR="${XDG_CACHE_HOME}" # a jar analyzer, from sdkman

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Uncomment either of these lines to enable bash-it doctor-like debugging
# n.b. There is no BASH_IT_LOG_LEVEL_DEBUG, but I keep thinking that's the name for trace when I ack for it
# export BASH_IT_LOG_LEVEL=6 # BASH_IT_LOG_LEVEL_INFO, ... which isn't available yet
# export BASH_IT_LOG_LEVEL=7 # BASH_IT_LOG_LEVEL_TRACE, which is the highes available. Only wsl seems to use it

# Path to the bash it configuration
export BASH_IT="${HOME}/.bash-it"
export VCSH_REPO_D="${XDG_CONFIG_HOME}/vcsh/repo.d"          # exporting the variable as its own self
export BASH_IT_DOTFILES_GIT_REPO="${VCSH_REPO_D}/config.git" # convention recommends bare repos end in .git
export WSL_WINDOWS_USER_HOME="/mnt/c/Users/Jake"

# This might be useful for a WSL 1 instance, where /usr/bin/git can be slower
#export SCM_GIT_SHOW_MINIMAL_INFO=true

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location /.bash_it/themes/
export BASH_IT_THEME='jake'

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
# export BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to the location of your work or project folders
BASH_IT_PROJECT_PATHS="${HOME}/wsl-projects:${HOME}/ms:${HOME}/wsl-projects/remarkable/repos" # gets too many duplicats if we include :${HOME}/projects"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true
# Set to actual location of gitstatus directory if installed
# clone from git@github.com:romkatv/gitstatus.git
export SCM_GIT_GITSTATUS_DIR="${HOME}/bin/gitstatus"
# To enable gitstatus logging:
# export GITSTATUS_LOG_LEVEL=INFO # or DEBUG (see gitstatus@github/src/logging.h)
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)

# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# If your theme use command duration, uncomment this to
# enable display of last command duration.
#export BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
#export COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# export BASH_IT_RELOAD_LEGACY=1

# Load Bash It
source "$BASH_IT"/bash_it.sh