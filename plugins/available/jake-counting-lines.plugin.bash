# shellcheck shell=bash
about-plugin 'get that sort | uniq -c | sort -n magic into a single command'

function counting {
	about 'sort the input lines by their frequency. Args are passed as-if to `sort -n `'
	sort | uniq -c | sort -n "$@" | pager
}
alias counted=counting
