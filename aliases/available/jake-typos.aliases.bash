# shellcheck shell=bash
about-alias "Jake's custom aliases for common typos in common and jake-custom scripts"

alias viim=vim
alias vimi=vim
alias vimn=vim # actual
alias vimm=vim # speculative
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
# TODO: this could be a function to check if our parent is also bash, and exit to it. Only print this message at top level
# Basically: exit, but don't exit if we'd lose the terminal
alias q="echo no need to quit - you are already out"

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

alias ltre=ltree
alias ltreee=ltree

alias ach=ack
alias akc=ack

# mt is actually a real command, but I don't plan on doing stuff with magnetic tape
alias mt=mr
alias m=mr

alias map=man # I'm kinda surprised there was no existing map command that this overrides
alias mabn=man

alias sork=sort

alias cata=cat
alias vat=cat
alias ca=cat
alias cag=cat
alias catg=cat
alias qcat=cat

# G is closer to B than C on the keyboard
alias gat=bat

# lls is define in jake-aliases. Basically ls | less
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
alias idf=diff
alias dif=diff
alias iff=diff
alias idff=diff
alias duff=diff
alias dfif=diff
alias didd=diff
alias dfiff=diff
alias difff=diff
alias diiff=diff

alias renite=remote
alias remotes=remote # technically, a different word, but it's the plural of the first and should do the same thing
alias branches=branch # ditto

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

alias grpe=grep

alias pgre=pgrep

alias vile=file
alias fiel=file
alias fild=file
alias fil=file

alias mkae=make
alias maek=make

alias tiem=time
alias ype=type

alias mcn=mvn
alias vmn=mvn

alias suod=sudo
alias suto=sudo
alias audo=sudo

alias ssg=ssh

alias pws=pwd

alias tyep=type
alias typeo=typo

alias whick=which # (to be fair, I was drinking at the time :| )

alias ipconfig=ifconfig

alias rakubew=rakubrew
alias rakub=rakubrew

# from jake-aliases - these are git command which drop the "git " prefix
alias stage=staged # NB: `git stage` is an alias for `git add`. This here is a TYPO of staged, not an attempt to use `git stage` conveniently
alias stsaged=staged
alias setaged=staged
alias stagerd=staged
alias stg=staged
alias sho=show
# some of these are handled by a "duplicating alias" too (so alias comm0t='git comm0t' would work) but it's better for
# them to be here than in jake-aliases which would imply that these are legitimate git commands.
# To handle these both with and without git requires duplication. I'd rather have that duplication in here than
# in jake-aliases. These are typo words, not git-command words.
# TODO: I wish there were a way to auto-correct `commit --amened` to `commit --amend`
alias comit=commit
alias comm9t=commit
alias comm0t=commit
alias comm-t=commit
alias commt=commit
alias cmmit=commit
alias cimmit=commit
alias vimmit=commit
alias commmit=commit
alias committ=commit
alias commit-a='commit -a'
alias commita='commit -a'
alias ignroed=ignored
alias restoer=restore
alias rain=rainbow
alias rainow=rainbow
alias rianbow=rainbow
alias rainboiw=rainbow
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
alias staqsh=stashs
alias stashs=stash
alias u=pull # more likely I was thinking of 'up', but that's just 'pull' anyway
alias p=pull
alias pu=pull
alias up=pull # Technically not a typo, but it's a typo of a typo, so I'm keeping it here
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
alias lop=logp
alias lgop=logp
alias lopg=logp
alias jfd=jdf

alias dockar=docker

# super eager with that second s
alias bashs=bash
alias bas=bash
# custom config command to manage dotfiles
alias confgi=config
alias cofngi=config
alias conifg=config
alias  confg=config
alias  cofig=config
alias  onfig=config
alias   nfig=config
alias   conf=config

alias ci=co
alias coi=co
