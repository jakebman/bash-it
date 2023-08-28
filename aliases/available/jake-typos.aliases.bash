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
alias ghit=git
alias gitt=git
alias jgti=git # it's like... sometimes I just mash the keyboard while thinking really hard about the command

# Not technically typos, but a common misstep:
alias :q="echo You are not in vim"
alias q="echo no need to quit - you are already out"

alias ks=ls
alias lss=ls
alias lsa='ls -a'
alias lsl='ls -l'
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

alias cata=cat
alias vat=cat
alias ca=cat
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
alias difff=diff
alias diiff=diff

alias bash0t=bash-it
alias bash0-t=bash-it
# my own tool that does apt updates
alias apt0up=apt-up

alias vd=cd
alias vf=cd # left hand misaligned
alias dc=cd
alias ce=cd
alias xs=cd

alias grpe=grep

alias vile=file
alias fiel=file

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
# some of these are handled by a "duplicating alias" too, but it's better for them to be here than in jake-aliases
# which would imply that these are legitimate git commands.
# To handle these both with and without git requires duplication. I'd rather have that duplication in here than
# in jake-aliases. These are typo words, not git-command words.
alias comit=commit
alias comm9t=commit
alias comm0t=commit
alias comm-t=commit
alias commt=commit
alias cimmit=commit
alias commit-a='commit -a'
alias commita='commit -a'
alias ignroed=ignored
alias restoer=restore
alias rianbow=rainbow
alias rainboiw=rainbow
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
alias stashs=stash
alias pu=pull
alias up=pull # Technically not a typo, but it's a typo of a typo, so I'm keeping it here
alias uop=pull # Actually a typo of up, which I'm using more as an alias of up, apparently
alias pul=pull
alias ull=pull
alias upll=pull
alias pulll=pull
alias puhs=push
alias pusl=push
alias psh=push
alias pus=push
alias ush=push
alias addd=add
alias ass=add
alias loig=log
alias lgop=logp
alias lopg=logp
alias jfd=jdf

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

alias coi=co
