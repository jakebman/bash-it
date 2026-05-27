# shellcheck shell=bash
about-plugin 'set BASH_IT_PROJECT_PATHS from BASH_IT_PROJECT_PATHS_CANDIDATES for pj'
# We need to load before the projects plugin, with default priority 250
# BASH_IT_LOAD_PRIORITY: 240

: "${BASH_IT_PROJECT_PATHS:=$HOME/Projects:$HOME/src:$HOME/work}"
if [ -v BASH_IT_PROJECT_PATHS ]; then
	_log_warning "BASH_IT_PROJECT_PATHS is already set. Not analyzing BASH_IT_PROJECT_PATHS_CANDIDATES"
	return
fi
for candidate in "${BASH_IT_PROJECT_PATHS_CANDIDATES[@]}"; do
	if [[ -d "$candidate" ]]; then
		# magic: use the "use this value if this variable is set syntax (`:+`)
		# to add a preceeding colon to each entry after the first
		BASH_IT_PROJECT_PATHS+="${BASH_IT_PROJECT_PATHS:+:}${candidate}"
	fi
done
unset -v candidate
