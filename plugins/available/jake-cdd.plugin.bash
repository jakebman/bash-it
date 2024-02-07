# shellcheck shell=bash
about-plugin 'some functions (cdd - go to parent folder of; cddd - go to grandparent folder of)'

# TODO: it might make an interesting exercise for these commands to *also* search in $CDPATH or respect other cd flags

function _cdd_dirname() {
	about "dirname doesn't know about . and .. entries. This method does"

	case "$(basename "$1")" in
		. | ..)
			echo "${1}/.."
			;;
		*)
			dirname "${1}"
			;;
	esac
}

function _cdd_any() {
	param "1: any number of additional '../..' suffixes to add to the first implicit .. (see the definition of cdd and cddd to see base cases for this)"
	param "2: cd-like argument, optional. Defaults to '.' (pwd)"

	local arg="${2-.}"
	local dir="$(_cdd_dirname "${arg}")"
	local suffix="$1"

	if [[ "." = "$dir" ]] && [[ -z "$suffix" ]]; then
		echo "silly goose. You.. sent yourself back to the current directory."
		# This special case only seems to apply to situations like `cdd asdf`
		# (I currently can't think of a reason for any `cddd <something here>` to fail in this way)
		return 1
	else
		cd "${dir}/${suffix}"
	fi
}

function cdd() {
	_cdd_any "" "$@"
}

function cddd() {
	_cdd_any ".." "$@"
}

function cdddd() {
	_cdd_any "../.." "$@"
}

function cddddd() {
	_cdd_any "../../.." "$@"
}

function cdddddd() {
	_cdd_any "../../../.." "$@"
}
