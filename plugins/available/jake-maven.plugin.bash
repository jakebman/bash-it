about-plugin "jake lazy maven commands"

alias go-offline='mvn dependency:go-offline'
alias effective-pom='mvn help:effective-pom'

function mvn-colored {
	command mvn "$@" -Dstyle.color=always
}

# Implicit paging!
function mvn {
	# output to terminal
	if [ -t 1 ]; then
		echo "Jake: paging maven output :D"

		# TODO: where is style.color documented?
		# TODO: once I'm using maven 3.9 (and not a lower version) I could use MAVEN_ARGS
		# see: https://maven.apache.org/configure.html
		# NB: We need all raw characters to support maven's overstrike/^M/bolding tech
		# And there's no reason not to start less following the output
		mvn-colored "$@" | less --raw-control-chars +F
	else
		command mvn "$@"
	fi
}
