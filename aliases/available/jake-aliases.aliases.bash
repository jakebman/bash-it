# shellcheck shell=bash
about-alias "Jake's custom commands that are aliases"

alias tulpn='netstat -tulpn'

# custom commands (they have typo entries, too)
alias lls='ll --color | less'
alias ltree='tree | less'

# It's functionally an alias; so sue me
function jqless {
  jq --color-output "$@" | less
}
