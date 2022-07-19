# shellcheck shell=bash
cite about-plugin
about-plugin 'Put ~/bin and ~/.local/bin on your path before ~/.profile does. Be sure to delete those phrases from .profile'

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
if grep --silent /bin ~/.profile ; then
  _log_error "~/.profile will potentially double-add entries for your bin folders. Please check this: $(grep -C2 /bin ~/.profile)"
fi
