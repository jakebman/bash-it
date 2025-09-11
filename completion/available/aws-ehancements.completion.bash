# shellcheck shell=bash
# Load after the the completion for other aliases, which loads at 800
# BASH_IT_LOAD_PRIORITY: 810

if _command_exists aws_completer; then
	complete -C "$(command -v aws_completer)" aws
fi
