# shellcheck shell=bash
about-plugin 'Allow certain folders to always remain valid `cd` targets, from anywhere (as if their parent dir is in CDPATH)'

# Implementation note: we accomplish this by combining two independent mechanisms:
# 1. Creating a special quick-access folder, with symlinks to chosen always-valid cd targets. That folder goes on CDPATH
# 2. Change cd so any single-word target that doesn't exist from `.` gets an implicit -P

# "Append the quick-access folder to the cd path"
# Automagically, however this also creates CDPATH with the initial "." entry, because
# "A null directory name is the same as the current directory", per `help cd`
CDPATH+=":${XDG_CONFIG_HOME:-${HOME}/.config}/cd/quick-access"

function cd {
	about 'normal `cd`, but non-$CWD entries get an implicit -P to follow symlinks'
	if [[ "$#" -eq 1 ]] && ! [[ -d "$1" ]]; then
		# Shim: I'm basically assuming all symlinks contained in non-$CWD entries in CDPATH are "less canonical"
		# than their targets.
		builtin cd -P "$@"
	else
		builtin cd "$@"
	fi
}
