# shellcheck shell=bash
about-plugin 'update things that need update and call out TODOs in the places I like'

function jake-maintain-system() {
  about "perform a bunch of maintenance tasks"
  : ${BASH_IT_MAINENANCE_DIR:=$HOME/.jake-maintenance-reports}
  mkdir -p "${BASH_IT_MAINENANCE_DIR}"
  function jake-log() {
	tee -a maintenance-log
  }
  (
  cd "${BASH_IT_MAINENANCE_DIR}"
  # |& is shorthand for 2>&1 |
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
