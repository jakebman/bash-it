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
	  # symbolic, overwriting, and not treating the destination as a directory for the link to be added to
	  # (but rather as a (symbolic link) file to be overwritten)
	  ln -s -f -T "$BASHPID" "${BASH_IT_MAINENANCE_DIR}/latest"
	  cd "${BASH_IT_MAINENANCE_DIR}/$BASHPID"
	  # |& is shorthand for 2>&1 |
	  echo "Logging begins. Check $(realpath maintenance-log) for updates" | jake-log

	  (config pull; config submodule update --init --remote --jobs 4 && echo "(logging note that submodule succeeded)") |& tee config-pull &
	  echo "$! spawned for config (and submodules!) pull" | jake-log
	  (cd "${BASH_IT}" && git pull) |& tee bash-it-pull &
	  echo "$! spawned for bash-it pull" | jake-log
	  for pid in `jobs -p`; do
		  wait $pid || echo PID $pid failed somehow | jake-log
	  done
	  echo "Done with git fetches"
	  sleep 2

	  (sdk selfupdate && echo updating sdk candidates && sdk update) |& tee sdk-man-update &
	  echo "$! spawned for sdkman update" | jake-log
	  # TODO: https://unix.stackexchange.com/questions/342663/how-is-unattended-upgrades-started-and-how-can-i-modify-its-schedule
	  echo "We should probably look into unattended-upgrade at https://unix.stackexchange.com/q/342663, and put that in the jake-install... script"
	  (sudo apt-update-only && echo "Listing..." && apt list --upgradable) |& tee apt-update &
	  echo "$! spawned for apt update" | jake-log

	  for pid in `jobs -p`; do
		  wait $pid || echo PID $pid failed somehow | jake-log
	  done
	  echo "done with all spawned processes" | jake-log
	  echo "find this log and others in $(realpath maintenance-log)" | jake-log
  )
  unset -f jake-log
}
