# shellcheck shell=bash
about-plugin 'load midnight-commander if you are using it'
if [[ -f /usr/lib/mc/mc.sh ]]; then
	  . /usr/lib/mc/mc.sh
fi
