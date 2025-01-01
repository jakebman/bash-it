cite about-plugin
about-plugin 'iotop requires sudo. Here is a function that implicitly sudos!'

function iotop() {
	sudo iotop "$@"
}
