# shellcheck shell=bash

# Two line prompt showing the following information:
# (time) SCM [username@hostname] pwd (SCM branch SCM status)
# →
#
# Example:
# (14:00:26) ± [foo@bar] ~/.bash_it (master ✓)
# →
#
# The arrow on the second line is showing the exit status of the last command:
# * Green: 0 exit status
# * Red: non-zero exit status
#
# The exit code functionality currently doesn't work if you are using the 'fasd' plugin,
# since 'fasd' is messing with the $PROMPT_COMMAND

PROMPT_END_CLEAN="${green}→${reset_color}"
PROMPT_END_DIRTY="${red}→${reset_color}"

prompt_setter() {
	local exit_status=$?

	# Microsoft Intelligent Terminal integration:
	printf '\033]133;D;%s\007' "$exit_status"
	printf '\033]9;9;%s\007' "${PWD:-}"
	# Comment copied from ~/.intelligent-terminal/shell-integration_v3.sh:
	# OSC 9001;ShellType — report shell identity each prompt so the terminal
	# always knows which shell owns the pane, even after a nested shell exits.
	# Under WSL, $WSL_DISTRO_NAME is set so we report "wsl:<distro>"; plain
	# (Git) bash reports "bash".
	if [ -n "${WSL_DISTRO_NAME:-}" ]; then
		printf '\033]9001;ShellType;wsl:%s;%s\007' "$WSL_DISTRO_NAME" "${BASH_VERSION:-}"
	else
		printf '\033]9001;ShellType;bash;%s\007' "${BASH_VERSION:-}"
	fi
	printf '\033]133;A\007'

	if [[ $exit_status -eq 0 ]]; then
		PROMPT_END=$PROMPT_END_CLEAN
	else
		PROMPT_END=$PROMPT_END_DIRTY
	fi
	# Save history
	_save-and-reload-history 1
	# ${WSL_DISTRO_NAME} is provided by WSL
	# ${VIRTUAL_ENV_PROMPT} is from python's venv
	PS1=""
	if ! [ -v INTELLIJ_TERMINAL_COMMAND_BLOCKS_REWORKED ]; then
		PS1+="\n"
	fi
	PS1+="($(clock_prompt))"
	PS1+=" $(scm_char)"
	PS1+=" [${blue}\u${reset_color}@${green}${WSL_DISTRO_NAME:-\H}${reset_color}]" # username@hostname, but use ws
	PS1+=" ${yellow}\w${reset_color}" # Working dir
	PS1+="$(scm_prompt_info)" # can be empty - adds its own preceeding space
	PS1+="\n" # newline
	PS1+="${VIRTUAL_ENV_PROMPT+${bold_purple}}${VIRTUAL_ENV_PROMPT-}"
	PS1+="${PROMPT_END}"
	PS1+="${VIRTUAL_ENV_PROMPT+ ${bold_purple}→${reset_color}}"
	PS1+=" "
	PS2='> '
	PS4='+ '
}

safe_append_prompt_command prompt_setter

SCM_THEME_PROMPT_DIRTY=" ${bold_red}X${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
