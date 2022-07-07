cite about-plugin
about-plugin 'Windows Subsystem for Linux interop'


wsl-dos2unix() {
  about 'convert window console output to what wsl commands expect (some windows commands like wsl.exe use UTF-16, which goozles grep)'
  example 'wsl.exe --list | wsl-dos2unix | grep Ubuntu'
  group 'wsl'
  iconv --from-code UTF-16LE --to-code UTF-8 | dos2unix
}


_wsl-find-windows-user-home() {
  about "Try to auto-discover \$WSL_WINDOWS_USER_HOME, which is the Windows user's home directory. Respects this variable if you set it manually"
  group 'wsl'
  # There's a lot of sturm und drang here to do the work automatically, but you can just specify it yourself
  # We need the wsl tools, which can be installed via an OS package named wslu or ubuntu-wsl
  # More details at https://wslutiliti.es/wslu/install.html
  if [ -z "$WSL_WINDOWS_USER_HOME" ] ; then
    if _command_exists wslvar ; then
      _log_debug "discovering \$WSL_WINDOWS_USER_HOME. Speed this up by specifying it manually"
      export WSL_WINDOWS_USER_HOME="$(wslpath "$(wslvar HOMEDRIVE)$(wslvar HOMEPATH)")"
      _log_debug "Speed up this command next time via export WSL_WINDOWS_USER_HOME='${WSL_WINDOWS_USER_HOME}'"
    else
      _log_error "wslvar not found. Specify WSL_WINDOWS_USER_HOME or get wslvar from wslu at https://github.com/wslutilities/wslu"
      return 1
    fi
  fi
  return
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
      _log_debug "${BARE_NAME} is already aliased to ${EXE} (nothing to do)"
      return 1
    fi
    _log_warning "An existing command supercedes ${BARE_NAME}: $(type "$BARE_NAME")"
    return 1
  fi
}

_wsl-alias-a-windows-exe() {
  about "create a 'foo' alias for any 'foo.exe' found on the path"
  param '1: the name of a windows executable'
  param '2*: (optional) paths where this executable could reside'
  example '_wsl-alias-a-windows-exe explorer.exe # equivalent to alias explorer=explorer.exe'
  group 'wsl'

  local BARE_NAME="${1%.exe}"
  local EXE="$(_wsl-find-a-windows-exe "$@")"

  if ! _command_exists "$EXE" ; then
    _log_debug "did not find ${EXE}"
    return 1
  fi

  if _check_exiting_commands "$BARE_NAME" "$EXE" ; then
    if alias "${BARE_NAME}='${EXE}'" ; then
      _log_debug "created alias $BARE_NAME for $EXE"
    else
      _log_error "could not create alias $BARE_NAME for $EXE"
    fi
  else
    return 1
  fi
}

_wsl-init() {
  about "do a bunch of work to make wsl more bearable - set up aliases, and forwarding shims"
  group 'wsl'

  if _wsl-alias-a-windows-exe notepad++.exe '/mnt/c/Program Files/Notepad++'\
       '/mnt/c/Program Files (x86)/Notepad++' ; then
    alias notepad=notepad++
    alias npp=notepad++
  fi

  _wsl-alias-a-windows-exe explorer.exe
  _wsl-alias-a-windows-exe wsl.exe
  _wsl-alias-a-windows-exe WinMergeU.exe '/mnt/c/Program Files/WinMerge/' && alias winmerge=WinMergeU

  _wsl-alias-a-windows-exe docker.exe  '/mnt/c/Program Files/Docker/Docker/resources/bin'
  _wsl-alias-a-windows-exe kubectl.exe '/mnt/c/Program Files/Docker/Docker/resources/bin'

  if _command_exists mvn ; then
    if _wsl-find-windows-user-home ; then
      if echo "${WSL_WINDOWS_USER_HOME}" | grep ' ' &>/dev/null ; then
        _log_warning "I'm sorry - I haven't been able to figure out how to escape spaces in the repostiory path"
      else
        export MAVEN_OPTS="-Dmaven.repo.local=${WSL_WINDOWS_USER_HOME}/.m2/repository"
      fi
    else
      _log_warning "unable to find Window's Maven repository. You might end up duplicating effort and files"
    fi
  fi

  # wsl.exe prints in window-y output (utf-16, CRLF), so we need to undo that for our unix tools
  local BASH_IT_WSL_VERSION=$(wsl.exe --list --running --verbose | wsl-dos2unix | grep  --word-regex "${WSL_DISTRO_NAME}" | awk '{print $NF}')

  # git is slow on version 1 WSLs. We save a bunch by doing this minimally
  [ "$BASH_IT_WSL_VERSION" == 1 ] && export SCM_GIT_SHOW_MINIMAL_INFO=true
}

_wsl-init
