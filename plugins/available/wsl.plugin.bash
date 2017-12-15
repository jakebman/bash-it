cite about-plugin
about-plugin 'Windows Subsystem for Linux interop'

__init_wsl() {
  local NPP='/mnt/c/Program Files (x86)/Notepad++'

  if [ -d "$NPP" ] ; then 
    PATH="$PATH:$NPP"
    alias npp='notepad++.exe'
    alias notepad++='notepad++.exe'
    alias notepad='notepad++.exe'
  fi
  alias explorer='explorer.exe'

  local DOCK='/mnt/c/Program Files/Docker/Docker/resources/bin'
  if [ -d "$DOCK" ] ; then
    PATH="$PATH:$DOCK"
    alias docker=docker.exe
  fi
}

__init_wsl
