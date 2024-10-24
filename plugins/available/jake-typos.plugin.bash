# shellcheck shell=bash
cite about-plugin
about-plugin "Jake's custom tool for common typos in common and jake-custom scripts"

# An analog to BASH_ALIASES
declare -A _BASH_IT_TYPOS

function typo {
	# TODO: error if there's an existing alias we'd overwrite. It's not perfect, but better than nothing
	local key val alias
	case $# in
		0)
			vim "$(realpath "${BASH_SOURCE}")"
			return
			;;
		1)
			val=${1#*=}
			key=${1%=$val}
			alias=$1
			;;
		2)
			key=$1
			val=$2
			alias="$key=$val"
			;;
		*) echo oops ;;
	esac
	# type: -a: all types, -f: ignore functions. This lets us find builtins shadowed by aliases (which I assume are just extras)
	if ((BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_TRACE)) \
		&& type -af "$val" |& grep -s -q 'is a shell builtin$' &> /dev/null; then
		# This is an expensive check, but worth it in tracing time
		_log_warning "this is an alias to a builtin: $alias"
		alias "$alias"
	fi
	_BASH_IT_TYPOS["$key"]=$val
}

function _typo-builtin {
	local key val alias
	key=$1
	val=$2
	alias="$key=$val"
	alias "$alias"
}

# https://mharrison.org/post/bashfunctionoverride/
# NB: this won't cover recursive functions properly
function save_function {
	local ORIG_FUNC=$(declare -f $1)
	local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
	eval "$NEWNAME_FUNC"
}

save_function command_not_found_handle _ububtu_command_not_found_handle
function command_not_found_handle {
	local -a args=("${@:2}")
	local name=$1
	echo "Typo identified: $name ${args[@]@Q}"
	if [ -z "${_BASH_IT_TYPOS["$name"]}" ]; then
		# we don't have a typo entry for this word. Follow the old path
		_ububtu_command_not_found_handle "$@"
		return
	fi

	_typos-load

	# TODO: can I get a printed bash stack trace?
	_log_debug "generated alias '$(type "$name")' for '$name'"
	if type -af "${_BASH_IT_TYPOS["$name"]}" |& grep -s -q 'is a shell builtin$' &> /dev/null; then
		_log_warning "$name is aliased to a builtin, ${_BASH_IT_TYPOS["$name"]}. It might be worth using the typo_builtin function instead"
	fi

	local - # local set -o stuff
	# TODO: Check if the outer bash is interactive
	shopt -qs expand_aliases
	# the arguments are 'quoted in a format that can be reused as input.' per Bash's @ "Parameter transformation"
	# @Q and :2 cannot be combined in the same substitution, though I didn't try very hard - this is far more readable
	# NB: this might be able to accomplished cleaner following the suggestion here:
	# https://unix.stackexchange.com/questions/444946/how-can-we-run-a-command-stored-in-a-variable#:~:text=in%20the%20end.-,Using%20an%20array%3A,-Arrays%20allow%20creating
	# (but it might be true that the quoted first argument defeats alias expansion)
	eval "$name" "${args[@]@Q}"
}

function _typos-load {
	local name
	for name in "${!_BASH_IT_TYPOS[@]}"; do
		alias -- "${name}=${_BASH_IT_TYPOS["$name"]}"
	done
}

function typos {
	(
		unalias -a
		_typos-load
		alias -p
	) \
		| sort \
		| pager
}

typo viim vim
typo vimi vim
typo vimn vim # actual
typo vimm vim # speculative
typo viom vim
typo ivm vim
typo vmi vim
typo vin vim
typo vun vim # right hand shifted left by one
typo gim vim
typo bim vim
typo cim vim
typo fim vim
typo vm vim
typo im vim

typo wimw vimw

typo it git
typo gi git
typo gir git
typo gti git
typo fir git
typo igt git
typo vit git
typo bit git
typo dit git
typo did git
typo fit git
typo fig git
typo tit git
typo got git
typo gut git
typo agit git
typo ghit git
typo gith git
typo ghti git
typo gitt git
typo gitr git
typo qgit git
typo jgti git # it's like... sometimes I just mash the keyboard while thinking really hard about the command

# Not technically typos, but a common misstep:
typo :q "echo You are not in vim"
typo :wq :q
typo wq :q

typo explorer. 'explorer .'
typo exploer. explorer. # happened while I was writing the alias above

typo htpo htop

# It's faster to just alias these to cht.sh and let the invocation fail later instead of checking for the existence of cht.sh
typo cht cht.sh
typo ch cht.sh

typo ks ls
typo lks ls
typo dls ls
typo lss ls
typo lsa 'ls -a'
typo lsl 'ls -l'
typo los ls
typo lh llh
typo les less
typo lesss less

typo ach ack
typo akc ack

# mt is actually a real command, but I don't plan on doing stuff with magnetic tape
typo mt mr

typo map man # I'm kinda surprised there was no existing map command that this overrides
typo amn man
typo mabn man

typo sork sort
typo sortr sort

typo shfmy shfmt
typo shf shfmt # tentative, sitting at the tab completion fork with shfolder.dll
typo shft shfmt
typo shfmty shfmt # speculative

typo cata cat
typo vat cat
typo ca cat
typo cag cat
typo catg cat
typo qcat cat

# G is closer to B than C on the keyboard
typo gat bat
typo bathhelp bathelp

# lls is define in jake-aliases. Basically ls | less
typo qls ls # I quit less *twice* then wanted to ls
typo lll lls
typo llls lls
typo llss lls
typo lle lls
typo lles lls
typo lless lls

typo tre tree
typo ree tree
typo tgree tree
typo treee tree

# These are times when I expected tree to have neither the depth nor count limits
typo treea ltree
typo treen ltree

typo deita delta

typo di diff
typo idf diff
typo dif diff
typo iff diff
typo idff diff
typo duff diff
typo dfif diff
typo didd diff
typo difdf diff
typo dfiff diff
typo difff diff
typo diiff diff

typo renite remote
typo remtoe remote
typo rewmote remote
typo remotes remote # technically, a different word, but it's the plural of the first and should do the same thing

typo bash0t bash-it
typo bash0-t bash-it
typo bashs-it bash-it
# my own tool that does apt updates
typo apt0up apt-up
typo aptup apt-up

typo note notepad

typo grpe grep

typo pgre pgrep

typo vile file
typo fiel file
typo fild file
typo fil file

typo mkae make
typo maek make
typo mane make

typo tiem time

typo mcn mvn
typo vmn mvn

typo suod sudo
typo suto sudo
typo audo sudo

typo ssg ssh

# The vars command is defined in .bash-it/custom, so it is defined *after* this, but it's fine to
# pre-declare aliases beforehand
typo vasr vars
typo cars vars

typo pyt python # technically, just a lazy name

# because that's what I was trying to type at the time, and I figure if I most-common'd
# 'type asdf' into 'typ easdf', it wouldn't work anyway
typo typ typo
typo ypo typo
typo fypo typo
typo tyop typo
typo tyypo typo
typo ytypo typo
typo typeo typo
typo typow typo

typo brwose browse

typo whick which # (to be fair, I was drinking at the time :| )
typo whic which
typo wich which

typo gind find

typo ipconfig ifconfig

typo rakubew rakubrew
typo rakub rakubrew

typo heml helm
typo kube kubectl
typo kubectyl kubectl
typo eks eksctl

# from jake-aliases - these are git command which drop the "git " prefix
typo stage staged # NB: `git stage` is an alias for `git add`. This here is a TYPO of staged, not an attempt to use `git stage` conveniently
typo stsaged staged
typo setaged staged
typo staghed staged
typo stagerd staged
typo stg staged
typo whow show
typo sho show
typo shw show
# some of these are handled by a "duplicating alias" too (so alias comm0t='git comm0t' would work) but it's better for
# them to be here than in jake-aliases which would imply that these are legitimate git commands.
# To handle these both with and without git requires duplication. I'd rather have that duplication in here than
# in jake-aliases. These are typo words, not git-command words.
# TODO: I wish there were a way to auto-correct `commit --amened` to `commit --amend`
typo githelp 'git help'
typo ammend amend
typo amned amend
typo amdne amend # jeez.
typo comit commit
typo ommit commit
typo comm9t commit
typo comm0t commit
typo comm-t commit
typo commt commit
typo cmmit commit
typo cimmit commit
typo vimmit commit
typo ocmmit commit
typo commmit commit
typo commi9t commit
typo commitm commit
typo commitmp commit # variants named from git's simplified version of these bash commands
typo commitpm commit
typo committ commit
typo commit-a 'commit -a'
typo commita 'commit -a'
typo ignroed ignored
typo rebas rebase
typo reabse rebase
typo restoer restore
typo retore restore
typo rstore restore
typo r-here rainbow-here
typo ra rainbow
typo rain rainbow
typo rainow rainbow
typo rainbo rainbow
typo rianbow rainbow
typo ranibow rainbow
typo rainboqw rainbow
typo rainboiw rainbow
typo raninbow rainbow
typo submodules submodule # in git-land, I consider this a "command I expected to work", but here in bash-land, I consider it closer to a typo
typo dubmodule submodule
typo submoduel submodule
typo submod submodule
typo setatus status
typo stsatus status
typo sstatus status
typo sttatus status
typo statuat status
typo statsus status
typo stauts status
typo statud status
typo statu status
typo staut status
typo tatus status
typo staus status
# NB: `stat` is an existing command. I needed a function to turn zero-arg `stat` into status, not just a simple alias
typo sta status
typo st status        # first unique difference from s's status-or-show magic
typo branche branches # because sometimes I get lazy, apparently
typo gst gstatus
typo staqsh stashs
typo stashs stash
typo tsga tags       # Wow.
typo unstasn unstash # Amusingly, a typo of a command I didn't even have before I made the typo. Now I do
typo pu pull
typo up pull  # Technically not a typo, but it's a typo of a typo, so I'm keeping it here
typo uop pull # Actually a typo of up, which I'm using more as an alias of up, apparently
typo uip pull
typo pul pull
typo ull pull
typo upll pull
typo pulll pull
typo puas push
typo puhs push
typo upsh push
typo pusl push
typo ppush push
typo pushb push
typo pusjh push
typo pushj push
typo push4 push
typo pushd push
typo psh push
typo pus push
typo puh push
typo ush push
typo cone clone
typo addd add
typo ass add
typo ad add
typo .og log
typo loig log
typo lig log
typo lob log
typo lop logp
typo logd logp # apparently log[D]iff makes sense if I forget it's actually [P]atch
typo lgop logp
typo lopg logp
typo yesteday yesterday
typo yest yesterday
typo wortree worktree
typo workdir worktree
typo jfd jdf
typo jdkf jdf
typo ws jws

# most likely something like "said [y] to a tool that already had --yes'd". Just succeed
typo y true

# shortened (typo-like) form of these "please definitely use git, and not bash, man, or mr" commands
typo ghelp githelp
typo gman gitman
typo gpull gitpull
typo gstatus gitstatus
typo gup gitpull

typo jjake jake # j!! on a jake
typo jske jake
typo jkae jake
typo jaek jake
typo vack jack

typo furl curl

# Because I apparently use this tool less frequently, and calling it by its full name... should have worked
typo sdkman sdk

typo mrdir rmdir

typo dockar docker
typo docksr docker
typo run docker-run

# super eager with that second s
typo bashs bash
typo bass bash
typo bas bash
# custom config command to manage dotfiles
typo confgi config
typo cofngi config
typo conifg config
typo cofnig config
typo confg config
typo cofig config
typo onfig config
typo nfig config
typo conf config

typo nns-conifg nns-config

typo sha256 sha256sum
typo sha sha256sum

# the git config-edit to edit "the appropriate" git config file
typo edit-config config-edit

typo ci co
typo coi co

#######################
## typos to builtins
## A bad shim until I figure something better
#######################

alias typo=_typo-builtin
typo '~cd' cd
typo vd cd
typo vf cd # left hand misaligned
typo dc cd
typo ce cd
typo ced cd
typo ccd cd
typo xs cd
typo qcd cd    # I quit less *twice*, then wanted to cd
typo lcd cd    # I tried to ls, then decided to change directories instead
typo treecd cd # Ditto, but tree. Wow.

typo hsitory history
typo pws pwd

typo tpe type
typo ype type
typo tyep type
typo tyoe type
typo yype type
typo typew type # ... because type already operates on its which (this might bite future me. Sorry, future me)

unalias typo
