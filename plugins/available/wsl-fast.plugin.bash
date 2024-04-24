cite about-plugin
about-plugin "Fire-and-forget-fast form of Windows Subsystem for Linux interop. While you're here, know about .wslconfig (WSL2 only): https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig"

if [ -d "$WSL_WINDOWS_USER_HOME" ]; then
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
if [[ -f "$NOTEPAD_LEGACY" ]] && [[ ! -f "$NOTEPAD" ]]; then
	NOTEPAD="$NOTEPAD_LEGACY"
fi
# NB: the single-quotes on ++ aren't necessary. They merely make vim's highlighting happier (and not notepad+ +=)
alias 'notepad++'="'$NOTEPAD'"
alias notepad="'$NOTEPAD'"
alias npp="'$NOTEPAD'"
unset NOTEPAD
unset NOTEPAD_LEGACY

alias explorer=explorer.exe
alias wsl=wsl.exe
alias winmerge="'/mnt/c/Program Files/WinMerge/WinMergeU.exe'"
alias winget=winget.exe

# don't worry about aliasing docker if it's already here
# TODO: when docker is /mnt/c/Program Files/Docker/Docker/resources/bin/docker, all it does is complain
# that it's not actually the right docker
if ! type docker &> /dev/null; then
	alias docker=docker.exe
	alias kubectl=kubectl.exe
fi

function windirstat {
	about "run windirstat.exe in a background process, willing to assume you mean the current folder"

	if [[ 0 -eq "$#" ]]; then
		'/mnt/c/Program Files (x86)/WinDirStat/windirstat.exe' . &
	else
		'/mnt/c/Program Files (x86)/WinDirStat/windirstat.exe' "$@" &
	fi
}

function wsl-open-port {
	about "learn more at https://learn.microsoft.com/en-us/windows/wsl/networking"
	param "1: port to open on linux side"
	param "2: port to open on windows side (optional - defaults to \$1)"
	: ${2:=$1}
	local linuxPort="$1"
	local windowsPort="$2"
	echo "This command requires windows-level Administrator permission."
	echo "I currently don't have a way to invoke that from wsl. (TODO!)"
	echo "however, you should be able to simply run this command:"
	echo netsh.exe interface portproxy add v4tov4 \
		listenport="$windowsPort" listenaddress=0.0.0.0 \
		connectport="$linuxPort" connectaddress="$(hostname -I)"
	echo "In an elevated commmand prompt"
}
