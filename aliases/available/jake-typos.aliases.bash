# shellcheck shell=bash
about-alias "Jake's custom aliases for common typos in common and jake-custom scripts"

alias viim=vim
alias vimi=vim
alias vimn=vim # actual
alias vimm=vim # speculative
alias viom=vim
alias ivm=vim
alias vmi=vim
alias vin=vim
alias vun=vim # right hand shifted left by one
alias gim=vim
alias bim=vim
alias cim=vim
alias fim=vim
alias vm=vim
alias im=vim
alias v=vim

alias it=git
alias gi=git
alias gir=git
alias gti=git
alias igt=git
alias vit=git
alias bit=git
alias dit=git
alias did=git
alias fit=git
alias fig=git
alias tit=git
alias got=git
alias gut=git
alias agit=git
alias ghit=git
alias gith=git
alias ghti=git
alias gitt=git
alias gitr=git
alias qgit=git
alias jgti=git # it's like... sometimes I just mash the keyboard while thinking really hard about the command

# Not technically typos, but a common misstep:
alias :q="echo You are not in vim"
alias :wq=:q
alias wq=:q

alias explorer.='explorer .'
alias exploer.=explorer. # happened while I was writing the alias above

alias hsitory=history

# It's faster to just alias these to cht.sh and let the invocation fail later instead of checking for the existence of cht.sh
alias cht=cht.sh
alias ch=cht.sh

alias ks=ls
alias lks=ls
alias lss=ls
alias lsa='ls -a'
alias lsl='ls -l'
alias los=ls
alias lh=llh
alias les=less
alias lesss=less

alias ach=ack
alias akc=ack

# mt is actually a real command, but I don't plan on doing stuff with magnetic tape
alias mt=mr
alias m=mr

alias map=man # I'm kinda surprised there was no existing map command that this overrides
alias amn=man
alias mabn=man

alias sork=sort

alias shfmy=shfmt
alias shfmty=shfmt # speculative

alias cata=cat
alias vat=cat
alias ca=cat
alias cag=cat
alias catg=cat
alias qcat=cat

# G is closer to B than C on the keyboard
alias gat=bat
alias bathhelp=bathelp

# lls is define in jake-aliases. Basically ls | less
alias qls=ls # I quit less *twice* then wanted to ls
alias lll=lls
alias llls=lls
alias llss=lls
alias lle=lls
alias lles=lls
alias lless=lls

alias tre=tree
alias ree=tree
alias treee=tree

alias d=diff
alias di=diff
alias idf=diff
alias dif=diff
alias iff=diff
alias idff=diff
alias duff=diff
alias dfif=diff
alias didd=diff
alias difdf=diff
alias dfiff=diff
alias difff=diff
alias diiff=diff

alias renite=remote
alias remotes=remote # technically, a different word, but it's the plural of the first and should do the same thing

alias bash0t=bash-it
alias bash0-t=bash-it
# my own tool that does apt updates
alias apt0up=apt-up

alias vd=cd
alias vf=cd # left hand misaligned
alias dc=cd
alias ce=cd
alias xs=cd
alias qcd=cd # I quit less *twice*, then wanted to cd
alias lcd=cd # I tried to ls, then decided to change directories instead

alias grpe=grep

alias pgre=pgrep

alias vile=file
alias fiel=file
alias fild=file
alias fil=file

alias mkae=make
alias maek=make

alias tiem=time

alias mcn=mvn
alias vmn=mvn

alias suod=sudo
alias suto=sudo
alias audo=sudo

alias ssg=ssh

alias pws=pwd

# The vars command is defined in .bash-it/custom, so it is defined *after* this, but it's fine to
# pre-declare aliases beforehand
alias vasr=vars
alias cars=vars

alias tpe=type
alias ype=type
alias tyep=type
alias tyoe=type
alias typew=type # ... because type already operates on its which (this might bite future me. Sorry, future me)
# because that's what I was trying to type at the time, and I figure if I most-common'd
# 'type asdf' into 'typ easdf', it wouldn't work anyway
alias typ=typo
alias fypo=typo
alias tyop=typo
alias ytypo=typo
alias typeo=typo

alias whick=which # (to be fair, I was drinking at the time :| )
alias whic=which

alias gind=find

alias ipconfig=ifconfig

alias rakubew=rakubrew
alias rakub=rakubrew

# from jake-aliases - these are git command which drop the "git " prefix
alias stage=staged # NB: `git stage` is an alias for `git add`. This here is a TYPO of staged, not an attempt to use `git stage` conveniently
alias stsaged=staged
alias setaged=staged
alias stagerd=staged
alias stg=staged
alias whow=show
alias sho=show
alias shw=show
# some of these are handled by a "duplicating alias" too (so alias comm0t='git comm0t' would work) but it's better for
# them to be here than in jake-aliases which would imply that these are legitimate git commands.
# To handle these both with and without git requires duplication. I'd rather have that duplication in here than
# in jake-aliases. These are typo words, not git-command words.
# TODO: I wish there were a way to auto-correct `commit --amened` to `commit --amend`
alias githelp='git help'
alias ammend=amend
alias amned=amend
alias comit=commit
alias comm9t=commit
alias comm0t=commit
alias comm-t=commit
alias commt=commit
alias cmmit=commit
alias cimmit=commit
alias vimmit=commit
alias ocmmit=commit
alias commmit=commit
alias commi9t=commit
alias committ=commit
alias commit-a='commit -a'
alias commita='commit -a'
alias ignroed=ignored
alias rebas=rebase
alias restoer=restore
alias ra=rainbow
alias rain=rainbow
alias rainow=rainbow
alias rainbo=rainbow
alias rianbow=rainbow
alias ranibow=rainbow
alias rainboqw=rainbow
alias rainboiw=rainbow
alias submoduel=submodule
alias submod=submodule
alias setatus=status
alias stsatus=status
alias sstatus=status
alias sttatus=status
alias statuat=status
alias statsus=status
alias stauts=status
alias statud=status
alias statu=status
alias staut=status
alias tatus=status
alias staus=status
alias st=status # first unique difference from s's status-or-show magic
alias branche=branches # because sometimes I get lazy, apparently
alias gst=gstatus
alias staqsh=stashs
alias stashs=stash
alias unstasn=unstash # Amusingly, a typo of a command I didn't even have before I made the typo. Now I do
alias u=pull          # more likely I was thinking of 'up', but that's just 'pull' anyway
alias p=pull
alias pu=pull
alias up=pull  # Technically not a typo, but it's a typo of a typo, so I'm keeping it here
alias uop=pull # Actually a typo of up, which I'm using more as an alias of up, apparently
alias pul=pull
alias ull=pull
alias upll=pull
alias pulll=pull
alias puhs=push
alias upsh=push
alias pusl=push
alias psh=push
alias pus=push
alias ush=push
alias addd=add
alias ass=add
alias loig=log
alias lig=log
alias lop=logp
alias lgop=logp
alias lopg=logp
alias yesteday=yesterday
alias yest=yesterday
alias wortree=worktree
alias workdir=worktree
alias jfd=jdf
alias jdkf=jdf
alias ws=jws

# shortened (typo-like) form of these "please definitely use git, and not bash, man, or mr" commands
alias ghelp=githelp
alias gman=gitman
alias gpull=gitpull
alias gstatus=gitstatus
alias gup=gitpull

alias jjake=jake # j!! on a jake
alias jske=jake
alias jkae=jake
alias vack=jack

alias dockar=docker

# super eager with that second s
alias bashs=bash
alias bas=bash
# custom config command to manage dotfiles
alias confgi=config
alias cofngi=config
alias conifg=config
alias cofnig=config
alias confg=config
alias cofig=config
alias onfig=config
alias nfig=config
alias conf=config

# the git config-edit to edit "the appropriate" git config file
alias edit-config=config-edit

alias ci=co
alias coi=co
