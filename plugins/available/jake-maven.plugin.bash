about-plugin "jake lazy maven commands"

alias go-offline='mvn dependency:go-offline'

# Implicit paging!
function mvn {
	# output to terminal
	if [ -t 1 ]; then
		echo "Jake: paging maven output :D"

		# TODO: where is style.color documented?
		# TODO: once I'm using maven 3.9 (and not a lower version) I could use MAVEN_ARGS
		# see: https://maven.apache.org/configure.html
		command mvn "$@" -Dstyle.color=always | less --RAW-CONTROL-CHARS
	else
		command mvn "$@"
	fi
}
