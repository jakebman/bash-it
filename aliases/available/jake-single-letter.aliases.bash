# shellcheck shell=bash
about-alias "Jake's source of truth for single-letter commands"

# Single-letter/alphabetical shortcut alaises
alias b=browse # or branch, bash, or bat?
# alias d=diff # currently in jake-typos.aliases.bash because it was a typo first
# alias f=fidget # defined in custom/jake.bash
alias g=git
unalias h
alias h=hgrep # replace the one from general with hgrep from jake-implicit-commands
# alias m=mr # typo
# alias p=pull # typo (TODO: could this become `push` if we're a commit ahead of upstream?)
# function q # in bash-it plugin jake-q. Approx: { if ! _is-toplevel-bash; then exit; fi }
alias r=realpath-and-rainbow # defined in jake-aliases, but fine to alias here
alias s=status-or-show       # defined in jake-aliases, but fine to alias here
# alias u=pull # typo; actually for 'up', but shortcutting
# alias v=vim # typo
