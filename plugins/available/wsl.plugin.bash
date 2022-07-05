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

  if which mvn &>/dev/null ; then
    export MAVEN_OPTS="-Dmaven.repo.local='${WINDOWS_HOME}/.m2/repository'"
  fi
}

__init_wsl
