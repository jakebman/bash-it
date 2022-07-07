cite about-plugin
about-plugin 'Windows Subsystem for Linux interop'

__find_windows_user_home() {
  # try to auto-discover the current Windows user's $HOME variable, which is not called that in Windows
  # There's a lot of sturm und drang here to auto-calculate it, but you can just specify it yourself
  # I recommend the wslu tools, but they're entirely optional if you set WSL_WINDOWS_USER_HOME yourself
  # You likely can install wslu via an OS package named wslu or ubuntu-wsl
  # More details at https://wslutiliti.es/wslu/install.html
  if [ -z "$WSL_WINDOWS_USER_HOME" ] ; then
    if _command_exists wslvar ; then
      _log_debug "discovering WSL_WINDOWS_USER_HOME. Speed this up by specifying it manually"
      export WSL_WINDOWS_USER_HOME="$(wslpath "$(wslvar HOMEDRIVE)$(wslvar HOMEPATH)")"
      _log_debug "Speed up this command next time via export WSL_WINDOWS_USER_HOME='${WSL_WINDOWS_USER_HOME}'"
    else
      _log_error "wslvar not found. Specify WSL_WINDOWS_USER_HOME or get wslvar from wslu at https://github.com/wslutilities/wslu"
      return 1
    fi
  fi
  return
}

function _command_exists_silently () {
  _command_exists "$@" &>/dev/null
}

__find_exe() {
  #TODO: docs
  EXE="${1?'need to find an exe'}"
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

__check_exiting_commands () {
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

__do_the_obvious_alias() {
  #TODO: docs
  local BARE_NAME="${1%.exe}"
  local EXE="$(__find_exe "$@")"

  if ! _command_exists "$EXE" ; then
    _log_debug "did not find ${EXE}"
    return 1
  fi

  if __check_exiting_commands "$BARE_NAME" "$EXE" ; then
    if alias "${BARE_NAME}='${EXE}'" ; then
      _log_debug "created alias $BARE_NAME for $EXE"
    else
      _log_error "could not create alias $BARE_NAME for $EXE"
    fi
  else
    return 1
  fi
}

__init_wsl() {
  if __do_the_obvious_alias notepad++.exe '/mnt/c/Program Files/Notepad++'\
       '/mnt/c/Program Files (x86)/Notepad++' ; then
    alias notepad=notepad++
    alias npp=notepad++
  fi
  __do_the_obvious_alias explorer.exe
  __do_the_obvious_alias wsl.exe
  __do_the_obvious_alias WinMergeU.exe '/mnt/c/Program Files/WinMerge/' && alias winmerge=WinMergeU

  __do_the_obvious_alias docker.exe  '/mnt/c/Program Files/Docker/Docker/resources/bin'
  __do_the_obvious_alias kubectl.exe '/mnt/c/Program Files/Docker/Docker/resources/bin'

  if _command_exists mvn ; then
    if __find_windows_user_home ; then
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
  local BASH_IT_WSL_VERSION=$(wsl.exe --list --running --verbose | iconv --from-code UTF-16LE --to-code UTF-8 | dos2unix | grep  --word-regex "${WSL_DISTRO_NAME}" | awk '{print $NF}')

  # git is slow on version 1 WSLs. We save a bunch by doing this minimally
  [ "$BASH_IT_WSL_VERSION" == 1 ] && export SCM_GIT_SHOW_MINIMAL_INFO=true
}

__init_wsl
