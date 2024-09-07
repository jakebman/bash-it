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
			echo "${BASH_SOURCE[*]}"
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
	_log_debug "$key is $val; aliasing $alias"
	_BASH_IT_TYPOS["$key"]=$val
}

# https://mharrison.org/post/bashfunctionoverride/
function save_function {
    local ORIG_FUNC=$(declare -f $1)
    local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
    eval "$NEWNAME_FUNC"
}

save_function command_not_found_handle _ububtu_command_not_found_handle
function command_not_found_handle {
	echo handling missing "$@";
	if [ -z "${_BASH_IT_TYPOS["$1"]}" ] || alias -- "$1"; then
		# it's not a typo - follow the old
		_ububtu_command_not_found_handle "$@";
		return
	fi

	# TODO: it might be useful to replace this loop with an array appending to BASH_ALIASES
	local name
	for name in "${!_BASH_IT_TYPOS[@]}"; do
		echo alias -- "${name}=${_BASH_IT_TYPOS["$name"]}"
	done

	local - # local set -o stuff
	# TODO: CHeck if the outer bash is interactive
	shopt expand_aliases
	"$@"
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
typo v vim

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

typo hsitory history

# It's faster to just alias these to cht.sh and let the invocation fail later instead of checking for the existence of cht.sh
typo cht cht.sh
typo ch cht.sh

typo ks ls
typo lks ls
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
typo m mr

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
typo treee tree
typo treen treeN

typo deita delta

typo d diff
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
typo rewmote remote
typo remotes remote # technically, a different word, but it's the plural of the first and should do the same thing

typo bash0t bash-it
typo bash0-t bash-it
# my own tool that does apt updates
typo apt0up apt-up
typo aptup apt-up

typo '~cd' cd
typo vd cd
typo vf cd # left hand misaligned
typo dc cd
typo ce cd
typo ced cd
typo xs cd
typo qcd cd    # I quit less *twice*, then wanted to cd
typo lcd cd    # I tried to ls, then decided to change directories instead
typo treecd cd # Ditto, but tree. Wow.

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

typo pws pwd

# The vars command is defined in .bash-it/custom, so it is defined *after* this, but it's fine to
# pre-declare aliases beforehand
typo vasr vars
typo cars vars

typo pyt python # technically, just a lazy name

typo tpe type
typo ype type
typo tyep type
typo tyoe type
typo yype type
typo typew type # ... because type already operates on its which (this might bite future me. Sorry, future me)
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
typo u pull          # more likely I was thinking of 'up', but that's just 'pull' anyway
typo p pull
typo pu pull
typo up pull  # Technically not a typo, but it's a typo of a typo, so I'm keeping it here
typo uop pull # Actually a typo of up, which I'm using more as an alias of up, apparently
typo uip pull
typo pul pull
typo ull pull
typo upll pull
typo pulll pull
typo puhs push
typo upsh push
typo pusl push
typo ppush push
typo pushb push
typo pusjh push
typo push4 push
typo pushd push
typo psh push
typo pus push
typo puh push
typo ush push
typo addd add
typo ass add
typo ad add
typo .og log
typo loig log
typo lig log
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

# super eager with that second s
typo bashs bash
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

# the git config-edit to edit "the appropriate" git config file
typo edit-config config-edit

typo ci co
typo coi co
