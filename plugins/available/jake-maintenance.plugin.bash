# shellcheck shell=bash
about-plugin 'update things that need update and call out TODOs in the places I like'

function jake-sdkman-update() {
	sdk selfupdate
	echo updating sdk candidates
	sdk update
}

function jake-maintain-system() {
	about "perform a bunch of maintenance tasks"
	echo "TODO: use the script terminal-recording tech"
	: ${BASH_IT_MAINTENANCE_DIR:=${XDG_STATE_HOME:-${HOME:-~}/.local/state}/jake-maintenance-reports}
	mkdir -p -- "${BASH_IT_MAINTENANCE_DIR}"
	function jake-log() {
		tee -a maintenance-log
	}
	(
		# $$ is the pid of the outer bash. This subshell's PID is $BASHPID
		mkdir -p "${BASH_IT_MAINTENANCE_DIR}/$BASHPID"
		# symbolic, overwriting, and not treating the destination as a directory for the link to be added to
		# (but rather as a (symbolic link) file to be overwritten)
		ln -s -f -T "$BASHPID" "${BASH_IT_MAINTENANCE_DIR}/latest"
		cd "${BASH_IT_MAINTENANCE_DIR}/$BASHPID"
		# |& is shorthand for 2>&1 |
		echo "Logging begins. Check" '${BASH_IT_MAINTENANCE_DIR}/latest' "($(realpath maintenance-log)) for updates" | jake-log

		(
			config pull --autostash
			config submodule update --init --remote --jobs 4 && echo "(logging note that submodule succeeded)"
		) |& tee config-pull &
		echo "$! spawned for config pull with autostash (and submodules!) pull" | jake-log
		echo "(bash-it pulling has been moved to pull function, which delegates to mr)"
		# local pid - not in a bash function context right now
		for pid in $(jobs -p); do
			# TODO: this is vulnerable to having an already-existing suspended job
			wait $pid || echo PID $pid failed somehow | jake-log
		done
		echo "Done with git fetches"
		sleep 2

		jake-sdkman-update |& tee sdk-man-update &
		echo "$! spawned for sdkman update" | jake-log
		# TODO: https://unix.stackexchange.com/questions/342663/how-is-unattended-upgrades-started-and-how-can-i-modify-its-schedule
		echo "We should probably look into unattended-upgrade at https://unix.stackexchange.com/q/342663, and put that in the jake-install... script"
		(sudo apt-update-only && echo "Listing..." && apt list --upgradable) |& tee apt-update &
		echo "$! spawned for apt update" | jake-log
		echo "TODO: clean up docker images if docker is present: https://rzymek.github.io/post/docker-prune/ (or docker system prune)"
		echo "TODO: for each pom.xml file in each subfolder of each element of BASH_IT_PROJECT_PATHS: do a mvn dependency:go-offline after a git update"
		echo "TODO: check each gradlew wrapper jdk candidate for being an sdkman-able jdk. Symlink it into sdkman's candidates (gradle can install its own jdks, and find sdkman's, but not ask sdkman to install a jdk)"
		# local pid - not in a bash function context right now
		for pid in $(jobs -p); do
			wait $pid || echo PID $pid failed somehow | jake-log
		done
		echo "done with all spawned processes" | jake-log
		echo "find this log and others in" '${BASH_IT_MAINTENANCE_DIR} -' "specifically $(realpath maintenance-log)" | jake-log
	)
	unset -f jake-log
}
