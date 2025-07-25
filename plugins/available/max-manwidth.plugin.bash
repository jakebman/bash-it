
about-plugin 'Keep $MANWIDTH no larger than $MAX_MANWIDTH - watching $COLUMNS and enabling MANWIDTH=MAX_MANWIDTH only when the screen is wider'

# TODO: should this have the BASH_IT_ prefix?
: ${MAX_MANWIDTH:=100}

function _maxManwidth_MaintainMaxManWidth {
	if (( COLUMNS > MAX_MANWIDTH )); then
		export MANWIDTH=$MAX_MANWIDTH
	else
		unset MANWIDTH
	fi
}

# A terminal can start up with a too-large size, and never receive SIGWINCH
_maxManwidth_MaintainMaxManWidth

trap _maxManwidth_MaintainMaxManWidth SIGWINCH
