# shellcheck shell=bash
about-alias 'walk back the batcat name for bat ("a cat(1) clone with wings")'
if _command_exists batcat; then
	alias bat=batcat
fi
