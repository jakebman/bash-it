# shellcheck shell=bash
about-alias 'Allow sudo to execute/expand aliases (sudo ll will work as sudo ls -l)'

# Per alias's help:
# "A trailing space in VALUE causes the next word to be checked for alias substitution when the alias is expanded."
alias sudo='sudo '
