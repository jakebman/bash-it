cite about-plugin
about-plugin 'Windows Subsystem for Linux interop'

__init_wsl() {
  local WINDOWS_HOME='/mnt/c/Users/P2776931'
  local NPP='/mnt/c/Program Files (x86)/Notepad++'
  if [ -d "$NPP" ] ; then
    PATH="$PATH:$NPP"
    alias npp='notepad++.exe'
    alias notepad++='notepad++.exe'
    alias notepad='notepad++.exe'
  fi
  alias explorer='explorer.exe'
  alias wsl='wsl.exe'

  local DOCK='/mnt/c/Program Files/Docker/Docker/resources/bin'
  if [ -d "$DOCK" ] ; then
    PATH="$PATH:$DOCK"
    alias docker=docker.exe
  fi

  if _command_exists mvn ; then
    export MAVEN_OPTS="-Dmaven.repo.local='${WINDOWS_HOME}/.m2/repository'"
  fi

  # wsl.exe prints in window-y output (utf-16, CRLF), so we need to undo that for our unix tools
  local BASH_IT_WSL_VERSION=$(wsl.exe --list --running --verbose | iconv --from-code UTF-16LE --to-code UTF-8 | dos2unix | grep  --word-regex "${WSL_DISTRO_NAME}" | awk '{print $NF}')

  # git is slow on version 1 WSLs. We save a bunch by doing this minimally
  [ "$BASH_IT_WSL_VERSION" == 1 ] && export SCM_GIT_SHOW_MINIMAL_INFO=true
}

__init_wsl
