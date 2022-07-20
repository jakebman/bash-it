# shellcheck shell=bash
about-alias "Jake's custom aliases for common typos and less-assuming commands"

alias vmi=vim
alias gim=vim
alias bim=vim
alias cim=vim
alias fim=vim
alias im=vim

alias it=git
alias gti=git
alias igt=git
alias vit=git
alias bit=git
alias fit=git
alias gitt=git

alias :q="echo You are not in vim"
alias q="echo no need to quit - you are already out"

alias lsa='ls -a'
alias les=less

# not a typo - presumes less on a command I like
# ... plus its typos
alias lls='ll --color | less'
alias lll=lls
alias llss=lls
alias lle=lls
alias lles=lls
alias lless=lls

alias tre=tree
alias ree=tree
alias treee=tree

# not a typo - presumes less on a command I like
# ... plus its typos
alias ltree='tree | less'
alias ltre=ltree
alias ltreee=ltree

alias vd=cd

alias grpe=grep

alias vile=file

# git commands that... I don't care to add git to
alias co='git co'
alias commit='git commit'
alias comit='git commit'
alias pull='git pull'
alias push='git push'
alias status='git status'
alias branch='git branch'
alias log='git log'

# custom config command to manage dotfiles
alias confgi=config
