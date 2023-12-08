cite about-plugin
about-plugin "Fire-and-forget-fast form of Windows Subsystem for Linux interop. While you're here, know about .wslconfig (WSL2 only): https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig"

if [ -d "$WSL_WINDOWS_USER_HOME" ] ; then
	export MAVEN_OPTS="-Dmaven.repo.local=${WSL_WINDOWS_USER_HOME}/.m2/repository"
else
	_log_warning "Set WSL_WINDOWS_USER_HOME to /mnt/c/Users/<your home dir> to unify maven repos"
fi

#wsl.exe prints in window-y output (utf-16LE, CRLF), so we need to undo that for our unix tools
wsl2unix() {
  about "a dos2unix for the output of wsl.exe, which seems to have weird output from our linux perspective"
    dos2unix --assume-utf16le "$@"
}

# TODO: these programs might live in Program Files (x86) instead
alias chrome="'/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'"

# TODO: Not sure I like this pattern, but it's an interesting first pass:
NOTEPAD="/mnt/c/Program Files/Notepad++/notepad++.exe"
NOTEPAD_LEGACY="/mnt/c/Program Files (x86)/Notepad++/notepad++.exe"
if [[ -f "$NOTEPAD_LEGACY" ]] && [[ ! -f "$NOTEPAD" ]] ; then
	NOTEPAD="$NOTEPAD_LEGACY"
fi
alias notepad="'$NOTEPAD'"
alias npp="'$NOTEPAD'"
unset NOTEPAD
unset NOTEPAD_LEGACY

alias explorer=explorer.exe
alias wsl=wsl.exe
alias winmerge="'/mnt/c/Program Files/WinMerge/WinMergeU.exe'"

# don't worry about aliasing docker if it's already here
# TODO: when docker is /mnt/c/Program Files/Docker/Docker/resources/bin/docker, all it does is complain
# that it's not actually the right docker
if ! type docker &>/dev/null ; then
	alias docker=docker.exe
	alias kubectl=kubectl.exe
fi
