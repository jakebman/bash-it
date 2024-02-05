# shellcheck shell=bash
cite about-plugin
about-plugin 'Put ~/bin and ~/.local/bin on your path before ~/.profile does. Be sure to delete those phrases from .profile'

# Load early, so that the commands in these locations are available to all alias _command_exists checks
# BASH_IT_LOAD_PRIORITY: 140


# these lines are from ubuntu's .profile file, modified to use bash-it's pathmunge
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  pathmunge "$HOME/bin"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  pathmunge "$HOME/.local/bin"
fi

# Now, emit an error if .profile will double-add these:
# -q -s is --quiet --no-messages (--silent is a synonym of --quiet). Means "no success output"; "no error output"
# I use the short forms here because alpine (busybox) doesn't know the long names
if grep -q -s /bin ~/.profile ; then
  _log_error "~/.profile will potentially double-add PATH entries for your bin folders. Please check this: $(grep -C2 /bin ~/.profile)"
fi
