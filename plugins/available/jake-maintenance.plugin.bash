# shellcheck shell=bash
about-plugin 'update things that need update and call out TODOs in the places I like'

function jake-maintain-system() {
  about "perform a bunch of maintenance tasks"
  : ${BASH_IT_MAINENANCE_DIR:=$HOME/.jake-maintenance-reports}
  function jake-log() {
	tee -a maintenance-log
  }
  (
  # $$ is the pid of the outer bash. This subshell's PID is $BASHPID
  mkdir -p "${BASH_IT_MAINENANCE_DIR}/$BASHPID"
  cd "${BASH_IT_MAINENANCE_DIR}/$BASHPID"
  # |& is shorthand for 2>&1 |

  config pull |& tee config-pull &
  echo "$! spawned for config pull" | jake-log
  (cd "${BASH_IT}" && git pull) |& tee bash-it-pull &
  echo "$! spawned for bash-it pull" | jake-log
  for pid in `jobs -p`; do
	  wait $pid || echo PID $pid failed somehow | jake-log
  done
  echo "Done with git fetches"
  sleep 2

  sdk update |& tee sdk-man-update &
  echo "$! spawned for sdkman update" | jake-log
  sudo apt update |& tee apt-update &
  echo "$! spawned for apt update" | jake-log

  for pid in `jobs -p`; do
	  wait $pid || echo PID $pid failed somehow | jake-log
  done
  echo "done with all spawned processes" | jake-log
  echo "find this log and others in $(realpath maintenance-log)" | jake-log
  )
  unset -f jake-log
}
