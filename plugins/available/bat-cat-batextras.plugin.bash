#! /bin/bash

cite about-plugin
about-plugin 'Tools to extend supporting bat, the cat replacement'

if _command_exists batcat && ! _command_exists bat; then
	alias bat=batcat
fi

if [[ "${BASH_IT_BAT_FOR_MAN:-1}" == 1 ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"

fi

if [[ "${BASH_IT_BAT_FOR_HELP:-1}" == 1 ]]; then
	if ! _command_exists bathelp; then
		# future-proof in case bathelp gets included in bat-extras
		alias bathelp='bat --plain --language=help'
	fi

	help() {
		"$@" --help 2>&1 | bathelp
	}
fi

