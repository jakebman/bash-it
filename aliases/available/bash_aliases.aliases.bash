# shellcheck shell=bash
cite 'about-alias'
about-alias 'import the existing aliases in .bash_aliases'

if [ -f "${HOME}/.bash_aliases" ]; then
	source "$HOME/.bash_aliases"
fi
