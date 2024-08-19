about-plugin "jake lazy maven commands"

alias go-offline='mvn dependency:go-offline'

# Implicit paging!
function mvn {
	# output to terminal
	if [ -t 1 ]; then
		echo "Jake: paging maven output :D"

		# TODO: where is style.color documented?
		command mvn "$@" -Dstyle.color=always | less --RAW-CONTROL-CHARS
	else
		command mvn "$@"
	fi
}
