cite about-plugin
about-plugin "Windows Subsystem for Linux interop. While you're here, know about .wslconfig (WSL2 only): https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig"

_wsl-has-tools() {
	about "Look for the wsl tools that the bash-it wsl plugin needs"
	group 'wsl'
	local success=0

	if ! _command_exists wslpath; then
		success=1
		_log_error "wslpath translates C:\\ to /mnt/c, and is usually added by WSL. You can try aliasing wsl_path from https://github.com/wslutilities/wslu to wslpath. (wsl_path is only deprecated because Microsoft has wslpath)"
	fi

	if ! _command_exists dos2unix; then
		success=1
		_log_error "dos2unix is necessary to translate newlines across. It's a common linux package. Failing that, you can probably alias dos2unix as \`tr -d \"\\r\\0\"\`"
	fi

	if ! _command_exists cmd.exe; then
		if ! _command_exists wslvar; then
			success=1
			_log_error "wslvar or cmd.exe help us read Windows environment variables"
			_log_error "cmd.exe is usually on the Window path, so I'm not sure why you don't have it, but wslvar is avaible from https://github.com/wslutilities/wslu"
		else
			_log_warning "uncertain where cmd.exe is, but we have wslvar, which works but is slow"
		fi
	fi

	return $success
}

#wsl.exe prints in window-y output (utf-16LE, CRLF), so we need to undo that for our unix tools
wsl-dos2unix() {
	about "a dos2unix for the output of wsl.exe, which seems to have weird output from our linux perspective"
	dos2unix --assume-utf16le "$@"
}

_wsl-find-windows-user-home() {
	about "Try to auto-discover \$WSL_WINDOWS_USER_HOME, which is the Windows user's home directory. Does nothing if \$WSL_WINDOWS_USER_HOME is already set"
	group 'wsl'
	if [ -n "$WSL_WINDOWS_USER_HOME" ]; then
		return # It's already been set by the user or calculated by us. Nothing more to do.
	fi

	# There's a lot of sturm und drang here to do the work automatically, but you can just specify it yourself
	local HELPFUL_MESSAGE="Set WSL_WINDOWS_USER_HOME to /mnt/c/Users/<your home dir> to not worry about this error"

	if ! _wsl-has-tools; then
		_log_warning "Insufficient tools to find WSL_WINDOWS_USER_HOME. $HELPFUL_MESSAGE"
		return 1
	fi

	if _command_exists_silently cmd.exe; then
		local winpath="$(
			cd /mnt/c
			cmd.exe /C "echo %HOMEDRIVE%%HOMEPATH%" | dos2unix
		)"
		export WSL_WINDOWS_USER_HOME="$(wslpath "$winpath")"
	elif _command_exists_silently wslvar; then
		_log_debug "discovering \$WSL_WINDOWS_USER_HOME via a slow method. You can specify it manually for a speedier startup"
		export WSL_WINDOWS_USER_HOME="$(wslpath "$(wslvar HOMEDRIVE)$(wslvar HOMEPATH)")"
		_log_warning "Speed up this command next time via export WSL_WINDOWS_USER_HOME='${WSL_WINDOWS_USER_HOME}'"
	else
		_log_error "internal logic error - _wsl-has-tools said we had cmd.exe or wslvar, and we have neither. $HELPFUL_MESSAGE"
		return 1
	fi
}

_binary_exists_silently() {
	_about 'checks for existence of a binary, silently'
	_param '1: command to check (as per _binary_exists)'
	_example '$ _binary_exists_silently this-binary-probably-does-not-exist'
	_group 'lib'
	# from _binary_exists
	# type -P "$1" &>/dev/null
	# But this is slightly faster:
	which "$1" &> /dev/null
}

_command_exists_silently() {
	_about 'checks for existence of a command, silently'
	_param '1: command to check (as per _command_exists)'
	_example '$ _command_exists_silently this-command-probably-does-not-exist'
	_group 'lib'
	# from _command_exists
	type -t "$1" &> /dev/null
}

_wsl-find-a-windows-exe() {
	about "sets WIN_EXE to a windows executable either on the path or in any provided folders (WIN_EXE is unset if no .exe is found)"
	param '1: the windows executable - either fully-qualified or a bare name (bare names are checked against the PATH, including whatever Windows gave us)'
	param '2*: (optional) more paths where this executable could reside'
	group 'wsl'

	unset WIN_EXE

	# is $1 a fully-qualified path or not?
	local dirname="$(dirname "$1")"
	if [ "$dirname" = '.' ]; then # dirname returns '.' if the path is just a filename; so we check the path
		local basename="$1"

		# this `which` invocation is 2x faster than _command_exists, and specifying a bare name means you're pretty
		# confident that this invocation will succeed. We'll win about 0.1s startup time by doing this
		if which "$1" &> /dev/null || _command_exists_silently "$1"; then
			WIN_EXE="$1"
			return
		fi
	else # a fully-qualified path
		local basename="$(basename "$1")"
		if [ -x "$1" ]; then
			WIN_EXE="$1"
			return
		fi
	fi

	for dir in "${@:2}"; do
		if [ -x "${dir}/${basename}" ]; then
			export WIN_EXE="${dir}/${basename}"
			return
		fi
	done

	# failed to find
	return 1
}

_check_has_existing_commands() {
	about "Logs facts about whether \$1 has any aliases or names that aren't \$2"
	param "1: the bare name you expect to exist"
	param "2: the expected value of an existing alias (if the bare name already references this alias, no warning is emitted)"
	group 'wsl'

	local bare_name="$1"
	local exe_file="$2"
	if ! _command_exists_silently "$bare_name"; then
		_log_debug "No existing command found for ${bare_name} - no problem if we alias it to ${exe_file}"
		return
	fi

	if type "$bare_name" | grep -q "${bare_name} is aliased to \`\"${exe_file}\"'"; then
		_log_debug "${bare_name} is already an alias for ${exe_file} (nothing to do)"
		return
	fi

	_log_warning "We are overwriting ${bare_name} with ${exe_file} ($(type "$bare_name" | head -n1 | sed -e 's/is/was previously/'))"
}

_wsl-alias-a-windows-exe() {
	about "create a 'foo' alias for any 'foo.exe' found on the path"
	param '1: the name of a windows executable. If fully-qualified, PATH is not checked'
	param '2*: (optional) paths where this executable could reside'
	example '_wsl-alias-a-windows-exe explorer.exe # equivalent to alias explorer=explorer.exe'
	group 'wsl'

	# early out, if the first guess wins
	# Unfortunately, this is a net perf loss. We're generally the producer of these aliases,
	# so this only speeds up the second bash shell
	#if alias "$bare_name" &>/dev/null ; then
	#  _log_debug "${bare_name} has an alias: $(alias "$bare_name")"
	#  return
	#fi

	if ! _wsl-find-a-windows-exe "$@"; then
		return 1
	fi
	# _wsl-find-a-windows-exe has set WIN_EXE

	local bare_name="$(basename "$WIN_EXE" | sed -e 's/\.exe$//g')" # strips .exe suffix

	if [ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_INFO?}" ]; then
		_check_has_existing_commands "$bare_name" "$WIN_EXE" # slow diagnostics
	fi

	alias "${bare_name}=\"${WIN_EXE}\"" || _log_error "could not create alias '${bare_name}' for '${WIN_EXE}'"

	unset WIN_EXE # clear the env from the return code of _wsl-find-a-windows-exe
}

_wsl-aliases() {
	about "set up aliases to common Windows .exes"
	group 'wsl'

	if _wsl-alias-a-windows-exe '/mnt/c/Program Files/Notepad++/notepad++.exe' \
		'/mnt/c/Program Files (x86)/Notepad++'; then
		alias notepad=notepad++
		alias npp=notepad++
	fi

	_wsl-alias-a-windows-exe explorer.exe
	_wsl-alias-a-windows-exe wsl.exe
	_wsl-alias-a-windows-exe '/mnt/c/Program Files/WinMerge/WinMergeU.exe' && alias winmerge=WinMergeU

	if _binary_exists_silently docker; then
		# check docker integration
		if _binary_exists_silently docker.exe && [ "$(dirname $(which docker))" = "$(dirname $(which docker.exe))" ]; then
			_log_warning "docker integration might not be set up properly. Aliasing docker and kubectly to their windows .exe(s)"
			alias docker=docker.exe
			alias kubectl=kubectl.exe
		fi
	else
		_wsl-alias-a-windows-exe '/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe'
		_wsl-alias-a-windows-exe '/mnt/c/Program Files/Docker/Docker/resources/bin/kubectl.exe'
	fi

	_wsl-alias-a-windows-exe '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe' '/mnt/c/Program Files (x86)/Google/Chrome/Application'

	if _command_exists mvn; then
		if _wsl-find-windows-user-home; then
			if echo "${WSL_WINDOWS_USER_HOME}" | grep -q ' '; then
				_log_warning "I'm sorry - I haven't been able to figure out how to escape spaces in the repostiory path - you might end up duplicating mvn repository between windows and linux"
			else
				export MAVEN_OPTS="-Dmaven.repo.local=${WSL_WINDOWS_USER_HOME}/.m2/repository"
			fi
		else
			_log_warning "unable to find Window's Maven repository. You might end up duplicating effort and files"
		fi
	fi
}

_wsl-find-wsl-version() {
	wsl.exe --list --running --verbose \
		| wsl-dos2unix \
		| grep -E "^\W+${WSL_DISTRO_NAME}\W+Running\W+[[:digit:]]+\W?$" \
		| awk '{print $NF}'
}
_wsl-wslversion-specific() {
	about "do work based on which version of WSL we're running in. This relies on knowing which distro we're running in"
	if [ -z "${BASH_IT_WSL_VERSION}" ]; then
		if [ -z "${WSL_DISTRO_NAME}" ]; then
			_log_error "Could not find WSL_DISTRO_NAME. We might not be in WSL"
			return 1
		fi
		if ! _command_exists dos2unix; then # wsl-dos2unix needs the real dos2unix
			_log_warning "please install dos2unix or set BASH_IT_WSL_VERSION manually"
			return 1
		fi

		export BASH_IT_WSL_VERSION=$(_wsl-find-wsl-version)
	fi

	_log_debug "WSL Version is ${BASH_IT_WSL_VERSION:-not known}"
	case "${BASH_IT_WSL_VERSION}" in
		1)
			_wsl-wslversion1
			;;
		2)
			_wsl-wslversion2
			;;
	esac
}

_wsl-wslversion1() {
	about "WSL version 1 specific actions"
	# git is slow on version 1 WSLs. We save a bunch by doing this minimally
	if [[ "$SCM_GIT_SHOW_MINIMAL_INFO" != 'true' ]]; then
		_log_warning "Enabling minimal git info in WSL 1, because it's slow"
		export SCM_GIT_SHOW_MINIMAL_INFO=true
	fi

}
_wsl-wslversion2() {
	about "WSL version 2 specific actions"
	# nothing to do
}

_wsl-aliases
_wsl-wslversion-specific
