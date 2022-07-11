cite about-plugin
about-plugin 'Windows Subsystem for Linux interop'

_wsl-has-tools() {
  about "Look for the wsl tools that the bash-it wsl plugin needs"
  group 'wsl'
  local success=0

  if !  _command_exists wslpath ; then
    success=1
    _log_error "wslpath translates C:\\ to /mnt/c, and is usually added by WSL. You can try aliasing wsl_path from https://github.com/wslutilities/wslu to wslpath. (wsl_path is only deprecated because Microsoft has wslpath)"
  fi

  if ! _command_exists dos2unix ; then
    success=1
    _log_error "dos2unix is necessary to translate newlines across. It's a common linux package. Failing that, you can probably alias dos2unix as \`tr -d \"\\r\\0\"\`"
  fi

  if ! _command_exists cmd.exe ; then
    if ! _command_exists wslvar ; then
      success=1
      _log_error "wslvar or cmd.exe help us read Windows environment variables"
      _log_error "cmd.exe is usually on the Window path, so I'm not sure why you don't have it, but wslvar is avaible from https://github.com/wslutilities/wslu"
    else
      _log_warning "uncertain where cmd.exe is, but we have wslvar, which works but is slow"
    fi
  elif ! _command_exists wslvar ; then
    _log_warning "the wslu suite might not be installed. It's useful, and available from https://github.com/wslutilities/wslu"
  fi

  return $success
}

_wsl-find-windows-user-home() {
  about "Try to auto-discover \$WSL_WINDOWS_USER_HOME, which is the Windows user's home directory. Does nothing if \$WSL_WINDOWS_USER_HOME is already set"
  group 'wsl'
  if [ -n "$WSL_WINDOWS_USER_HOME" ] ; then
    return # It's already been set by the user or calculated by us. Nothing more to do.
  fi

  # There's a lot of sturm und drang here to do the work automatically, but you can just specify it yourself
  local HELPFUL_MESSAGE="Set WSL_WINDOWS_USER_HOME to /mnt/c/Users/<your home dir> to not worry about this error"

  if ! _wsl-has-tools ; then
    _log_warning "Insufficient tools to find WSL_WINDOWS_USER_HOME. $HELPFUL_MESSAGE"
    return 1
  fi

  if _command_exists_silently cmd.exe ; then
    local winpath="$(cd /mnt/c; cmd.exe /C "echo %HOMEDRIVE%%HOMEPATH%" | dos2unix)"
    export WSL_WINDOWS_USER_HOME="$(wslpath "$winpath")"
  elif _command_exists_silently wslvar ; then
    _log_debug "discovering \$WSL_WINDOWS_USER_HOME via a slow method. You can specify it manually for a speedier startup"
    export WSL_WINDOWS_USER_HOME="$(wslpath "$(wslvar HOMEDRIVE)$(wslvar HOMEPATH)")"
    _log_warning "Speed up this command next time via export WSL_WINDOWS_USER_HOME='${WSL_WINDOWS_USER_HOME}'"
  else
    _log_error "internal logic error - _wsl-has-tools said we had cmd.exe or wslvar, and we have neither. $HELPFUL_MESSAGE"
    return 1
  fi
}

_command_exists_silently() {
  _about 'checks for existence of a command, silently'
  _param '1: command to check (as per _command_exists)'
  _param '2: (optional) log message to include when command not found (as per _command_exists)'
  _example '$ _command_exists_silently this-command-probably-does-not-exist'
  _group 'lib'
  _command_exists "$@" &>/dev/null
}

_wsl-find-a-windows-exe() {
  about "find a windows executable either on the path or in any provided folders"
  param '1: the windows executable'
  param '2*: (optional) paths where this executable could reside'
  group 'wsl'

  EXE="${1?'need to specify an exe to find'}"
  if _command_exists_silently "$EXE" ; then
    echo "$EXE"
    return
  fi

  shift # get $EXE out of $@ before we iterate over it

  for dir in "$@"; do
    if _command_exists_silently "${dir}/${EXE}" ; then
      echo "${dir}/${EXE}"
      return
    fi
  done
}

_check_exiting_commands () {
  about "diagnostics about existing aliases or programs"
  param "1: the bare name you expect to exist"
  param "2: the expected value of an existing alias (if the bare name already references this alias, no warning is emitted)"
  group 'wsl'

  local BARE_NAME="$1"
  if _command_exists_silently "$BARE_NAME" ; then
    local EXE="$2"
    if type "$BARE_NAME" | grep "${BARE_NAME} is aliased to \`'${EXE}''" &>/dev/null ; then
      _log_debug "${EXE} is already aliased by ${BARE_NAME} (nothing to do)"
      return 1
    fi
    _log_warning "An existing command supercedes ${BARE_NAME}: $(type "$BARE_NAME")"
    return 1
  fi
}

_wsl-alias-a-windows-exe() {
  about "create a 'foo' alias for any 'foo.exe' found on the path"
  param '1: the name of a windows executable. If fully-qualified, PATH is not checked'
  param '2*: (optional) paths where this executable could reside'
  example '_wsl-alias-a-windows-exe explorer.exe # equivalent to alias explorer=explorer.exe'
  group 'wsl'

  # use basename and dirname on $1 to allow for a fully-qualified first parameter
  local basename="$(basename "$1")"
  local dirname="$(dirname "$1")"
  local EXE="$(_wsl-find-a-windows-exe "$basename" "$dirname" "$@")"

  if ! _command_exists_silently "$EXE" ; then
    _log_warning "did not find an executable for '$1'"
    return 1
  fi

  local BARE_NAME="${basename%.exe}"

  if ! _check_exiting_commands "$BARE_NAME" "$EXE" ; then
    return 1
  fi

  if alias "${BARE_NAME}='${EXE}'" ; then
    _log_debug "created alias ${BARE_NAME} for ${EXE}"
  else
	  _log_error "could not create alias $BARE_NAME for $EXE"
  fi
}

_wsl-init() {
  about "do a bunch of work to make wsl more bearable - set up aliases, and forwarding shims"
  group 'wsl'

  if _wsl-alias-a-windows-exe '/mnt/c/Program Files/Notepad++/notepad++.exe'\
       '/mnt/c/Program Files (x86)/Notepad++' ; then
    alias notepad=notepad++
    alias npp=notepad++
  fi

  _wsl-alias-a-windows-exe explorer.exe
  _wsl-alias-a-windows-exe wsl.exe
  _wsl-alias-a-windows-exe '/mnt/c/Program Files/WinMerge/WinMergeU.exe' && alias winmerge=WinMergeU

  _wsl-alias-a-windows-exe '/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe'
  _wsl-alias-a-windows-exe '/mnt/c/Program Files/Docker/Docker/resources/bin/kubectl.exe'

  if _command_exists mvn ; then
    if _wsl-find-windows-user-home ; then
      if echo "${WSL_WINDOWS_USER_HOME}" | grep ' ' &>/dev/null ; then
        _log_warning "I'm sorry - I haven't been able to figure out how to escape spaces in the repostiory path - you might end up duplicating mvn repository between windows and linux"
      else
        export MAVEN_OPTS="-Dmaven.repo.local=${WSL_WINDOWS_USER_HOME}/.m2/repository"
      fi
    else
      _log_warning "unable to find Window's Maven repository. You might end up duplicating effort and files"
    fi
  fi

  # do work based on which version of WSL we're running in. This relies on knowing which distro we're running in
  if [ -n "${WSL_DISTRO_NAME}" ] ; then
    # wsl.exe prints in window-y output (utf-16LE, CRLF), so we need to undo that for our unix tools
    local BASH_IT_WSL_VERSION=$(wsl.exe --list --running --verbose | dos2unix --assume-utf16le | grep  --word-regex "${WSL_DISTRO_NAME}" | awk '{print $NF}')

    # git is slow on version 1 WSLs. We save a bunch by doing this minimally
    [ "$BASH_IT_WSL_VERSION" == 1 ] && export SCM_GIT_SHOW_MINIMAL_INFO=true
  fi
}

_wsl-init
