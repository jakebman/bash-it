# shellcheck shell=bash
about-plugin 'install the tools that Jake wants with jake-install-tools'

function _jake-find-tool() {
	if ! _binary_exists "$1"; then
		local to_install="${2:-${1}}"
		if [ $# -gt 2 ]; then
			local comment=" ($3)"
		fi
		echo "Did not find binary for ${1}${comment}. Adding $to_install to apt list"
		TOOLS_TO_INSTALL="${TOOLS_TO_INSTALL} ${to_install}"
	fi
}

function _jake-find-spelling() {
	if ! _binary_exists "spell"; then
		if ! _binary_exists "aspell"; then
			local to_install="spell"
			echo "Did not find binary for spell or aspell. Adding $to_install to apt list"
			TOOLS_TO_INSTALL="${TOOLS_TO_INSTALL} ${to_install}"
		fi
	fi
}

function _jake-find-file() {
	if ! [ -f "$1" ]; then
		local to_install="${2:-$(basename ${1})}"
		if [ $# -gt 2 ]; then
			local comment=" ($3)"
		fi
		echo "Did not find file at ${1}${comment}. Adding $to_install to apt list"
		TOOLS_TO_INSTALL="${TOOLS_TO_INSTALL} ${to_install}"
	fi
}

function jake-update-expected-git-version() {
	local GIT_VERSION="$(git --version)"
	# careful - there are two different quoting styles on this same s///:
	# ' reduces backslashes
	# " holds ' and interpolates variables
	sed --follow-symlinks --in-place -E 's/(^\s+)local EXPECTED_VERSION=.*/\1local EXPECTED_VERSION='"'${GIT_VERSION}'/" "$BASH_SOURCE"
	echo "The updated version is now: (if there is no output, we likely failed)"
	grep "'${GIT_VERSION}'" "$BASH_SOURCE"
}

function _jake-same-timestamp() {
	about "succeeds if the two given files have the same timestamp"
	param "1 & 2: files to compare"
	[[ "$1" -nt "$2" ]] && return 1
	[[ "$1" -ot "$2" ]] && return 1
	return 0
}

function jake-install-tools() {
	about "installs the tools jake uses"

	_jake-remove-motd-junk

	# tools that we can silently install
	if ! _binary_exists ack; then
		echo "installing the single-file version of ack!"
		_jake-update-ack-and-its-manpages
		echo # spacing
	else
		echo "Nothing to do for ack - ack already exists"
	fi

	if _jake-same-timestamp /usr/share/doc/git/contrib/git-jump/git-jump ~/bin/git-jump; then
		# A timestamp isn't the best indicator for this, but it's the best I have for the moment.
		# Also, allows me to 're-install' just by touching my copy
		echo "Nothing to do for git-jump - git-jump's timestamp is the same as in git's contrib/"
	else
		if ! _binary_exists git-jump; then
			echo "Installing git-jump"
		else
			echo "Updating git-jump"
		fi
		# preserve-timestamp isn't super helpful, given that we patch and then overwrite, but still..
		# it's the principle of the matter
		install --preserve-timestamps /usr/share/doc/git/contrib/git-jump/git-jump --target-directory ~/bin
		patch ~/bin/git-jump "${BASH_IT_CUSTOM}/etc/git-jump.patch"
		touch -r /usr/share/doc/git/contrib/git-jump/git-jump ~/bin/git-jump
	fi

	# TODO: it would be nice to have instructions that turn on APT::Get::Always-Include-Phased-Updates
	# read more at https://discourse.ubuntu.com/t/phased-updates-in-apt-in-21-04/20345/24

	# tools that can use apt
	TOOLS_TO_INSTALL=""
	_jake-find-tool pygmentize python3-pygments
	_jake-find-tool procyon procyon-decompiler # java class files. TODO - does this require OS-level java 11? can I sdkman around it? (via just installing the dependencies)
	_jake-find-tool python python-is-python3   # also grabs python3, as a bonus
	# _jake-find-tool xmlformat xmlformat-perl # I think xmlindent is cleaner, partially because it has fewer options
	_jake-find-tool xmllint libxml2-utils # multi-function, but only used for --xpath queries, because --format makes --xpath return one-line results
	_jake-find-tool redis-cli redis-tools
	_jake-find-tool make build-essential
	_jake-find-tool mkisofs genisoimage 'work tool to bundle rpms into an iso file'
	_jake-find-tool ifconfig net-tools
	_jake-find-tool nslookup dnsutils "for wsl-vpnkit, but I'm not certain nslookup is the required command. Could be dig or similar"
	_jake-find-tool apt-file apt-file 'and run `sudo apt-file update` after!'
	_jake-find-tool browse xdg-utils "slightly heavy, but a nice enhancement to open urls or files. Maybe --no-install-recommends?"
	_jake-find-tool sponge moreutils 'a tee that can write back to the original file of a pipeline :)'
	_jake-find-tool xeyes x11-apps "because I really like googly eyes"
	_jake-find-tool wslview wslu "installs wslview, which is an /etc's alternative x-www-browser (but not www-browser - lynx wins that bid)"
	_jake-find-tool ts moreutils 'timestamps its stdin and sends it to stdout (technically, we double-count moreutils, but I want this too)'
	_jake-find-tool rpmbuild rpm 'work tool to build rpms'
	_jake-find-tool http httpie
	_jake-find-tool asciidoctor
	_jake-find-tool git-extras
	_jake-find-tool xmlindent # doesn't have --long-options, which is a little weird, but formats all XML (incl. xmllint --xpath results), so that's good
	_jake-find-tool colordiff
	_jake-find-tool dos2unix
	_jake-find-tool neofetch "neofetch --no-install-recommends" "Has a recommended dependency on imagemagick, which is ~100MB of extras I don't need or want"
	_jake-find-tool debtree # to backtrace apt packages
	# TODO: Deprecating - haven't found it useful, nor missed it in its absence
	# _jake-find-tool thefuck # potentially not super compatible with bash-it :(
	_jake-find-tool unzip
	_jake-find-tool clang
	_jake-find-tool iotop
	_jake-find-tool gh gh "github cli"
	_jake-find-tool cmake cmake 'optional - used by the reMarkable suite'
	# _jake-find-tool g++ # I prefer clang for now
	_jake-find-tool ncdu
	_jake-find-tool tree
	_jake-find-tool zip
	_jake-find-tool jq
	# _jake-find-tool an an "an anagram tool" # meh - webapp seems just as fine
	_jake-find-spelling

	# not necessary, but nice:
	_jake-find-tool lynx

	# playing with these
	_jake-find-tool wajig # Doesn't have docs, but https://unix.stackexchange.com/questions/40442/which-installed-software-packages-use-the-most-disk-space-on-debian
	_jake-find-tool shfmt
	_jake-find-tool shellcheck
	_jake-find-tool mr myrepos
	_jake-find-tool qdirstat
	_jake-find-tool vcsh
	_jake-find-tool pip python3-pip "to install git-big-picture"
	_jake-find-tool perldoc perl-doc "for man mr"
	_jake-find-tool ctags universal-ctags "for vim navigation"
	_jake-find-tool figlet figlet "for my git no-args tools"
	_jake-find-file /usr/lib/git-core/git-gui git-gui "git commit gui; not dispatched-to via the path"
	# 228MB - only when you need it: _jake-find-tool ffmpeg

	_jake-find-jekyll
	_jake-find-file /usr/share/dict/words wamerican "the words list"

	if [ -n "$TOOLS_TO_INSTALL" ]; then
		echo ===== Your Installation Command ===========
		echo sudo apt install $TOOLS_TO_INSTALL
		echo ===== Your Installation Command ===========
		echo # spacing
	else
		echo "Nothing to do for all the apt packages - nothing to install there; apt is happy"
	fi

	# tools that require a manual intervention
	if ! _command_exists sdk; then
		echo "sdkman not found! Install via instructions at https://sdkman.io/install."
		echo -e "\t" "BE CAREFUL WHEN YOU PIPE TO BASH!!! THAT IS A BAD IDEA!!!"
		echo -e "\t" "curl --silent --show-error 'https://get.sdkman.io?rcupdate=false' --output ~/install-sdkman.sh"
		echo -e "\t" "vim ~/install-sdkman.sh"
		echo -e "\t" "~/install-sdkman.sh"
		echo -e "\t" "bash-it enable plugin sdkman"
		echo # spacing
	else
		echo "Nothing to do for sdkman - sdkman is happy"
	fi

	# I would really prefer to use the latest git
	local GIT_VERSION="$(git --version)"
	local EXPECTED_VERSION='git version 2.46.0'
	# TODO: it would be nice to be able to compare versions better
	# 1/2: Does https://github.com/fsaintjacques/semver-tool work?
	if [ "$GIT_VERSION_MAJOR" != "$EXPECTED_VERSION" ]; then
		local GIT_VERSION_MAJOR=$(echo $GIT_VERSION | sed -E -n 's/.* ([0-9]+)\..*/\1/p')
		local GIT_VERSION_MINOR=$(echo $GIT_VERSION | sed -E -n 's/.* ([0-9]+)\.([0-9]+)\..*/\2/p')
		local GIT_VERSION_PATCH=$(echo $GIT_VERSION | sed -E -n 's/.* ([0-9]+)\.([0-9]+)\.([0-9]+).*/\3/p') # n.b.: no trailing dot on this version #
		local EXPECTED_MAJOR=$(echo $EXPECTED_VERSION | sed -E -n 's/.* ([0-9]+)\..*/\1/p')
		local EXPECTED_MINOR=$(echo $EXPECTED_VERSION | sed -E -n 's/.* ([0-9]+)\.([0-9]+)\..*/\2/p')
		local EXPECTED_PATCH=$(echo $EXPECTED_VERSION | sed -E -n 's/.* ([0-9]+)\.([0-9]+)\.([0-9]+).*/\3/p') # n.b.: no trailing do on this version #
		local STANCE='too old'
		if [ "$GIT_VERSION_MAJOR" -gt "$EXPECTED_MAJOR" ]; then
			STANCE='newer'
		elif [ "$GIT_VERSION_MAJOR" -eq "$EXPECTED_MAJOR" ]; then
			if [ "$GIT_VERSION_MINOR" -gt "$EXPECTED_MINOR" ]; then
				STANCE='newer'
			elif [ "$GIT_VERSION_MINOR" -eq "$EXPECTED_MINOR" ]; then
				if [ "$GIT_VERSION_PATCH" -gt "$EXPECTED_PATCH" ]; then
					STANCE='newer'
				elif [ "$GIT_VERSION_PATCH" -lt "$EXPECTED_PATCH" ]; then
					STANCE='patch' #forgivable
				else
					STANCE='identical'
				fi
			fi
		fi # no need to check too-old state
		case "$STANCE" in
			'too old')
				echo "git is not very new - ${GIT_VERSION}, behind ${EXPECTED_VERSION}. Try grabbing their ppa:"
				echo -e "\t" "sudo add-apt-repository ppa:git-core/ppa"
				echo -e "\t" "sudo add-apt-repository ppa:git-core/candidate"
				echo -e "\t" "sudo apt update"
				echo # spacing
				;;
			patch)
				echo "git is only off by a patch version - not super important, but know that ${GIT_VERSION} is behind ${EXPECTED_VERSION}. Try grabbing their ppa:"
				echo -e "\t" "sudo add-apt-repository ppa:git-core/ppa"
				echo -e "\t" "sudo add-apt-repository ppa:git-core/candidate"
				echo -e "\t" "sudo apt update"
				echo # spacing
				;;
			newer)
				echo "the installed git is newer than the one that I'd ask you to install"
				echo "It's worth updating this upgrade script's line from:"
				echo -e "\t" "local EXPECTED_VERSION='$EXPECTED_VERSION'"
				echo "to:"
				echo -e "\t" "local EXPECTED_VERSION='$GIT_VERSION'"
				echo "via jake-update-expected-git-version"
				echo # spacing
				;;
			identical)
				echo "Nothing to do for git - git is happy at '$GIT_VERSION'"
				;;
		esac
	fi

	# don't need these, but should report them anyway
	_jake-check-optional-tools

	# Some things (sudo systemctl edit) end up ignoring my EDITOR env. There are two paths to fix this,
	# and we might as well call out both here:

	# Using the editor alternatives ("[If no $EDITOR env fallback chain], systemctl will try to execute well known editors in this order: editor(1), nano(1), vim(1)")
	if update-alternatives --query editor | grep Value: | grep -q -v vim; then
		echo "vim is not the default editor in update-alternatives"
		echo "Figure out what it's supposed to be with:" '$(update-alternatives --query vim | grep Best:)'
		echo "(That's $(update-alternatives --query vim | grep Best:))"
		echo "Then set it:"
		echo -en "\t"
		echo 'sudo update-alternatives --set editor ....'
	fi

	# Allowing the $EDITOR environment variables to pass through sudo
	# ref for script: https://superuser.com/questions/869144/why-does-the-system-have-etc-sudoers-d-how-should-i-edit-it
	if ! [[ -f /etc/sudoers.d/100-jake-sudoers && -f /etc/sudoers.d/200-preserve-LESS-env-var ]]; then
		echo "I'd like to preserve my \$EDITOR and \$LESS environment variable when editing. Please make sure we have that in /etc/sudoers.d"
		echo "You can find those files in ${BASH_IT_CUSTOM}/sudoers.d/"
		echo "(Heads up: files in sudoers.d can't have dots in them or they're ignored!)"
		echo "Copy it into the /etc/sudoers.d directory, but it needs to be root-owned, and only root-group-readable:"
		echo -en "\t"
		echo "find '${BASH_IT_CUSTOM}/sudoers.d/' -type f -print0 | xargs --null -L1 visudo --check --file"
		echo -en "\t"
		echo "find '${BASH_IT_CUSTOM}/sudoers.d/' -type f -print0 | xargs --null sudo install --compare --mode 0440 --target-directory /etc/sudoers.d/"
	fi

	local -a bin_files
	local bin_file
	for bin_file in $(ls "${BASH_IT_CUSTOM}/bin"); do
		if ! cmp -s "${BASH_IT_CUSTOM}/bin/${bin_file}" "/usr/local/bin/${bin_file}"; then
			bin_files+=($bin_file)
		fi
	done

	# https://serverfault.com/questions/477503/check-if-array-is-empty-in-bash
	if ((${#bin_files[@]})); then
		echo "please copy the apt* files (${bin_files[*]}) from ${BASH_IT_CUSTOM}/bin to /usr/local/bin"
		echo -en "\t"
		echo 'sudo install --verbose ${BASH_IT_CUSTOM}/bin/* /usr/local/bin'
	else
		echo "Nothing to do for apt-*-only - bin files are installed and are happy"
	fi

	if grep -q 'systemd=true' /etc/wsl.conf; then
		echo "Nothing to do for systemd - systemd is enabled in WSL"
	else
		echo "systemd is not enabled in wsl. Enable it with the instructions here:"
		echo "https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/"
	fi

	# Caveat: apt does not have a stable CLI output, and so this ^Listing grep:
	# 1) Might not be necessary later
	# 2) Might completely suppress desired output
	# ... I'm not super worried
	local apt_output=$(apt list --upgradeable 2> /dev/null | grep -v ^Listing)
	if [ -z "${apt_output}" ]; then
		echo "Nothing to do for apt updates - apt finds no upgradeable packages"
	else
		echo "Apt would love to install these updates (use sudo apt-upgrade-only to apply):"
		echo "$apt_output"
		echo "Thanks, apt!"
	fi
	local when
	if when="$(_jake-last-update)"; then
		echo -e "And the apt update is from ${echo_red-}${when}${echo_reset_color-}"
		echo -e "      A reminder: today is $(date)"
	else
		echo -e "${echo_red-}${when}${echo_reset_color-}"
	fi

	# let's make sure blue is readable while we're here
	echo -en "btw, "
	echo -en "${echo_blue-}if ${echo_reset_color-}"
	echo -en "this blue "
	echo -en "${echo_blue-}is ${echo_reset_color-}"
	echo -en "hard "
	echo -en "${echo_blue-}to ${echo_reset_color-}"
	echo -e "read,"
	echo -en "${echo_blue-}"
	echo "check out https://devblogs.microsoft.com/commandline/updating-the-windows-console-colors/"
	echo -en "${echo_reset_color-}"

	# TODO: recommend git config --global --set core.fsmonitor true for windows
}

# https://askubuntu.com/questions/410247/how-to-know-last-time-apt-get-update-was-executed
function _jake-last-update {
	if [ -f /var/lib/apt/periodic/update-success-stamp ]; then
		date -d "$(stat --format %y /var/lib/apt/periodic/update-success-stamp)"
	else
		echo "(apt's update-success-stamp file is missing)"
		return 1
	fi
}

function _jake-find-jekyll() {
	# https://jekyllrb.com/docs/installation/ubuntu/:
	_jake-find-tool ri ruby-full "ruby-full is ruby + ruby-dev + ri. ri seems like the most appropriate executable to test"
	_jake-find-file /usr/include/zlib.h zlib1g-dev "for jekyll, per https://jekyllrb.com/docs/installation/ubuntu/"
	if ! _command_exists gem; then
		echo "gem isn't installed - comes with ruby-full"
		echo "gem for jekyll not found - install it with 'sudo gem install jekyll bundler'"
	elif ! gem list jekyll | grep -q jekyll; then
		echo "gem for jekyll not found - install it with 'sudo gem install jekyll bundler'"
	fi
}

function _jake-check-optional-tools() {
	about "install tools that aren't necesarily required"

	if ! _command_exists gitstatus_check; then
		echo "gitstatus not found! It's a submodule of my dotfiles repo. Or you can install it manually:"
		echo -e "\t" "config submodule update --init"
		echo -e "\t" "git clone git@github.com:romkatv/gitstatus.git ~/bin/gitstatus # manually"
		echo -e "\t" '# And be sure that SCM_GIT_GITSTATUS_DIR="${HOME}/bin/gitstatus"' # single-quote saves escaping
	else
		echo "Nothing to do for gitstatus - gitstatus is happy"
	fi

	if _command_exists httpx; then
		echo "Nothing to do for httpx - httpx is happy"
	else
		# TODO: this might be deprecated
		echo "httpx not found! Install it from one of these: (it's a zip file with the executable in it)"
		_jake-github-repo-release-urls httpx-sh/httpx | grep linux | grep -v alligator # final nonsense to remove highlighting
	fi

	if _command_exists mvn; then
		echo "Nothing to do for maven - maven is happy"
	else
		echo "maven is available via sdkman: sdk install maven # latest version chosen by default"
	fi

	if _command_exists fzf; then
		# TODO: better version checking sounds like a good idea
		# 2/2: Does https://github.com/fsaintjacques/semver-tool work?
		if [[ "$(fzf --version)" =~ ^0.[123] ]]; then
			echo "fzf version is too low. Please uninstall it and reinstall it"
		else
			echo "Nothing to do for fzf - fzf is happy"
		fi
	else
		echo "Please install fzf - a dependency for my j script. Apt has an old version. I like 0.38.0"
		_jake-github-repo-release-urls junegunn/fzf | grep linux | grep amd | grep -v alligator # alligator is nonsense to remove highlighting
		echo "plus the manpage:"
		echo -en "\t"
		echo 'wget --directory-prefix ${HOME}/bin/man/man1/ https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 && mandb --user-db'
	fi

	if _command_exists helm; then
		echo "Nothing to do for helm - helm is happy"
	else
		echo "Please install helm - the package manager for kubernetes that I use at work"
		echo "Get the package from"
		_jake-github-repo-release-urls helm/helm | grep linux | grep 64 | grep -v arm
		echo -en "\t"
		echo 'tar xzf helm*tar*; install helm*/helm ~/bin'
		echo -en "\t"
	fi

	if _command_exists pyenv; then
		echo "Nothing to do for pyenv - jira is happy"
	else
		echo "Please install pyenv - a sdkman equivalent for python"
		echo "Follow the instructions at https://github.com/pyenv/pyenv-installer, that basically boil down to:"
		echo -en "\t"
		echo 'PYENV_ROOT=~/.local/lib/pyenv curl https://pyenv.run | bash'
	fi

	if _command_exists jira; then
		echo "Nothing to do for jira - jira is happy"
	else
		echo "Please install jira - the cli tool for atlassian's jira"
		echo "Get the package from"
		_jake-github-repo-release-urls ankitpokhrel/jira-cli | grep linux | grep 64 | grep -v alligator # alligator is nonsense to remove highlighting
		echo -en "\t"
		echo 'tar xzf jira*tar*; install jira*/bin/jira ~/bin'
		echo -en "\t"
		echo 'jira man --generate --output ~/bin/man/man7 && mandb --user-db'
	fi

	if _binary_exists bat; then
		echo "Nothing to do for bat - bat is happy"
	else
		echo "Please install bat - a dependency for my j script. The version installed from apt names the binary batcat. I don't like that"
		echo "Get the new .deb from one of these:"
		_jake-github-repo-release-urls sharkdp/bat | grep deb$ | grep amd | grep -v musl
		echo -en "\t"
		echo 'sudo dpkg -i bat*.deb && sudo apt-mark hold bat # keep apt from installing over this version'
		echo 'use apt-mark showhold to list the held packages'
	fi

	if _binary_exists delta; then
		echo "Nothing to do for delta - delta is happy"
	else
		echo "Please install delta - a bat-smart diff."
		echo "Get the new .deb from one of these, or via cargo from https://github.com/dandavison/delta"
		_jake-github-repo-release-urls dandavison/delta | grep deb$ | grep amd | grep -v musl
		echo -en "\t"
		echo 'sudo dpkg -i git-delta*.deb'
	fi

	if _binary_exists glab; then
		echo "Nothing to do for glab - glab is happy"
	else
		echo "Please install glab - gitlab's cli tool (parallels github's gh)"
		echo "Get the new .deb from one of these, or via https://gitlab.com/gitlab-org/cli/-/releases"
		_jake-gitlab-repo-release-urls 34675721 | grep deb$ | grep x86_64 | grep -v musl
		echo -en "\t"
		echo 'sudo dpkg -i glab_*.deb'
	fi

	if _binary_exists jless; then
		echo "Nothing to do for jless - jless is happy"
	else
		echo "Please install jless - a cli json gui"
		echo "Get the zip file and put it in ~/bin, or via https://github.com/PaulJuliusMartinez/jless/releases"
		_jake-github-repo-release-urls PaulJuliusMartinez/jless | grep -v apple-darwin
		echo -en "\t"
		echo 'unzip jless*.zip # -d ~/bin'
	fi

	if _binary_exists rancher; then
		echo "Nothing to do for rancher - rancher is happy"
	else
		echo "Please get rancher - the cli tool to access charter's rancher"
		echo "Get the zip file and put it in ~/bin"
		_jake-github-repo-release-urls PaulJuliusMartinez/jless | grep -v apple-darwin | grep -v windows
	fi

	if _command_exists asciinema; then
		# -w -q -s is --word-regexp --quiet --no-messages (--silent is a synonym of --quiet).
		# Means "surround with word barriers"; "no success output"; "no error output"
		# I use the short forms here because alpine (busybox) doesn't know the long names
		if grep -w -q -s asciinema /etc/apt/sources.list /etc/apt/sources.list.d/*; then
			echo "Nothing to do for asciinema - we have the ppa and asciinema is happy"
		else
			echo "asciinema is installed, but please add the ppa via:"
			echo -en "\t"
			echo 'sudo add-apt-repository ppa:zanchey/asciinema'
		fi
	else
		echo "Please install asciinema via:"
		echo -en "\t"
		echo 'sudo add-apt-repository ppa:zanchey/asciinema'
		echo -en "\t"
		echo 'sudo apt install asciinema'
	fi

	if _binary_exists git-delta; then
		# TODO: I don't see evidence that this command exists, especially not where I say it came from
		# 1) which git-delta am I thinking about removing here and 2) is it still around?
		echo "git-extras's git-delta shadows my git-delta alias. Pleas remove it with"
		echo -en "\t"
		echo 'sudo rm "$(which git-delta)"'
	fi
	if _binary_exists git-alias; then
		# TODO: I don't see evidence that this command exists, especially not where I say it came from
		# 1) which git-alias am I thinking about removing here and 2) is it still around?
		echo "git-extras's git-alias shadows my git-alias alias. Pleas remove it with"
		echo -en "\t"
		echo 'sudo rm "$(which git-alias)"'
	fi

	if _binary_exists git-authors; then
		echo "git-extras's git-authors shadows my git-authors alias (and is also strange). Pleas remove it with"
		# Strange: If you run git-authors in the folder where git-authors's source lives, its output is appended
		# to its own source code
		echo -en "\t"
		echo 'sudo rm "$(which git-authors)"'
	fi

	if _binary_exists git-cp; then
		echo "git-extras's git-cp shadows my git-cp alias (and also doesn't copy history). Pleas remove it with"
		# Strange: If you run git-authors in the folder where git-authors's source lives, its output is appended
		# to its own source code
		echo -en "\t"
		echo 'sudo rm "$(which git-cp)"'
	fi

	if _command_exists git-vendor; then
		echo "Nothing to do for git-vendor - git-vendor is happy"
	else
		echo "Consider installing git-vendor - it's a tool for bash-it vendor management from https://github.com/Tyrben/git-vendor"
	fi

	if _command_exists makedeb; then
		echo "Nothing to do for makedeb - makedeb is happy"
	else
		echo "consider looking into makedeb for my own packages - https://www.makedeb.org/"
	fi

	if _command_exists dgit; then
		echo "Nothing to do for dgit - dgit is happy"
	else
		echo "consider installing dgit for my own packages"
	fi

	if _command_exists git-big-picture; then
		echo "Nothing to do for git big picture - git-big-picture is happy"
	else
		echo "consider installing git big picture via 'pip install git-big-picture', because it looks pretty"
	fi

	if _command_exists raku; then
		echo "Nothing to do for raku - raku is happy"
	else
		echo "Consider installing rakudo, either via apt install rakudo or the more-complex:"
		echo -en "\t"
		echo "sudo apt install cpanminus; sudo cpanm CPAN && cpan Log::Log4perl && cpan YAML && cpan App::Rakubrew && \\"
		echo -en "\t"
		echo "rakubrew mode shim && rakubrew download 2023.08 # or the latest version marked with D from rakubrew list-available"
		echo -en "\t"
		echo "rakubrew build-zef && zef install Linenoise # for line-reading"
	fi
}

# TODO: both users of this method would like progressive filtering
# Basically: give me the deb that is amd, and non-musl, but if nothing is found, print the best list available
# (this might be a cool use-case for fzf... aside from the fact that I'm 100% intending to run this code *in order to* prompt myself to install fzf)
function _jake-github-repo-release-urls {
	about "list download urls for a release"
	param "1: repo, in <user>/<repo> format. Like sharkdp/bat"

	# NB: this could be `gh api "repos/${1}/releases/latest" --jq '.assets[].browser_download_url'
	# ... if we weren't in the bootstrap space where gh might not be available
	local URL="https://api.github.com/repos/${1}/releases/latest"
	# --location follows 301 redirects, like for httpx-sh/httpx, which goes to a numeric value
	curl -s --location "$URL" \
		| jq -r '.assets[].browser_download_url' \
		|| echo "failure to read from ${URL}"
}
# variant for gitlab
function _jake-gitlab-repo-release-urls {
	about "list download urls for a release"
	param "1: the numeric identifier of a project. Like 34675721 for https://gitlab.com/gitlab-org/cli. Requires a little work to figure out (I peeked at web requests to the API, myself)"

	# TODO: you might be able to use the <user-or-group>/<repo> system here, if you translate / into %2F, per:
	# https://docs.gitlab.com/ee/api/rest/#namespaced-path-encoding
	local URL="https://gitlab.com/api/v4/projects/${1}/releases/permalink/latest"
	# --location follows 301 redirects, like for httpx-sh/httpx, whicah goes to a numeric value
	curl -s --location "$URL" \
		| jq -r '.assets.links[].url' \
		|| echo "failure to read from ${URL}"
}

function _jake-remove-motd-junk {
	_jake-remove-motd-news
	_jake-remove-pro-news
}

function _jake-remove-motd-news {
	if grep -q ENABLED=1 /etc/default/motd-news; then
		echo "ubuntu news is polluting the MOTD. Fix it with:"
		echo -en "\t"
		echo "sudo  sed -i -e 's/^ENABLED=1/ENABLED=0 # disabled by Jake/' /etc/default/motd-news"
	fi
}

function _jake-remove-pro-news {
	if pro config show apt_news | grep -q True; then
		echo "Pro news is showing in apt. I don't like that."
		echo -en "\t"
		echo "sudo pro config set apt_news=False"
	fi
}

function _jake-update-ack-and-its-manpages {
	local bin_dir="${HOME}/bin"
	local man_dir="${bin_dir}/man"
	local ack_url="${1:-https://beyondgrep.com/ack-v3.7.0}"

	# I'm learning about manpages, so this first implementation is likely bad
	mkdir -p "${man_dir}/man1" # ack's manpage goes in man1. Add others here as needed

	local previous_ack_version
	if _command_exists ack; then
		previous_ack_version="$(ack --version | grep ack)"
	fi

	# instructions from https://beyondgrep.com/install/
	# I wish they had a -latest option.
	if curl "$ack_url" > "${bin_dir}/ack" && chmod 0755 "${bin_dir}/ack"; then
		echo "created ack at ${bin_dir}/ack"
		# We disable color on ls because I don't want to have this one weird colored line
		ls -l --human-readable --color=never "${bin_dir}/ack"
	else
		echo "failed"
		return 1
	fi

	echo # spacing

	if _command_exists pod2man; then
		local manfile="${man_dir}/man1/ack.1p"
		pod2man ~/bin/ack > $manfile
		echo "manfile created at ${manfile}. It looks like:"
		ls -l --human-readable "$manfile"
	else
		echo "please install pod2man. Probably via apt install perl"
		return 1
	fi

	echo # spacing

	if _command_exists mandb; then
		mandb --user-db || return 1
		echo # spacing
		echo mandb user db updated
	else
		echo "please install mandb. Otherwise, this won't work"
		return 1
	fi

	echo # spacing

	if [ -n "$previous_ack_version" ]; then
		echo "Checking against previous ack version..."
		echo "$previous_ack_version" | grep ack
		echo # spacing
		if ack --version | grep -q "$previous_ack_version"; then
			echo "This was the previous ack version. No update actually occurred. Check https://beyondgrep.com/install/ for a newer version"
			echo "You can modify this script, or simply pass the new url to this script"
		else
			echo "This ack version differs from the previous one. Yay!"
		fi
	else
		echo "This appears to be your first ack version - welcome to ack!"
	fi
}
