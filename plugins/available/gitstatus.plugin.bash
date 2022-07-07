cite about-plugin
about-plugin 'speeds up your life by using gitstatus for git status calculations. install from https://github.com/romkatv/gitstatus'

function gitstatus_on_disable() {
  about 'Destructor of gitstatus plugin'
  group 'gitstatus'

  unset SCM_GIT_USE_GITSTATUS
  _command_exists gitstatus_stop && gitstatus_stop
}

# No scm-check
[[ $SCM_CHECK == "true" ]] || return

# non-interactive shell
[[ $- == *i* ]] || return

: "${SCM_GIT_GITSTATUS_DIR:="$HOME/gitstatus"}"
if [[ -d ${SCM_GIT_GITSTATUS_DIR} ]]; then
  source "${SCM_GIT_GITSTATUS_DIR}/gitstatus.plugin.sh"
  # Start the actual gitstatus binary
  if gitstatus_stop && gitstatus_start -s 1 -u 1 -c 1 -d 1; then
    _log_debug "gitstatus daemon pid: ${GITSTATUS_DAEMON_PID}"
    export SCM_GIT_USE_GITSTATUS=true
  else
    _log_warning "gitstatus failed to start"
  fi
else
	_log_warning "Could not find gitstatus directory in ${SCM_GIT_GITSTATUS_DIR}. Please specify directory location using SCM_GIT_GITSTATUS_DIR."
fi
