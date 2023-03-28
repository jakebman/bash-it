
# One of the options described in https://news.ycombinator.com/item?id=11070797
# at https://news.ycombinator.com/item?id=11070797
about-plugin "Following the ideas at https://www.atlassian.com/git/tutorials/dotfiles"

# Convention is that a bare git repo has a .git suffix
: "${BASH_IT_DOTFILES_GIT_REPO:=~/.dotfiles-repo.git}"

if ! [ -d "${BASH_IT_DOTFILES_GIT_REPO}" ] ; then
  _log_error "${BASH_IT_DOTFILES_GIT_REPO} (\${BASH_IT_DOTFILES_GIT_REPO}) is not a valid git dir."
  _log_error "Try 'git init --bare \${BASH_IT_DOTFILES_GIT_REPO}' to create it,"
  _log_error "Or 'git clone \${YOUR_GIT_URL} --bare \${BASH_IT_DOTFILES_GIT_REPO}' to get it from somewhere else"
  _log_error "or set BASH_IT_DOTFILES_GIT_REPO to your bare git directory"
  _log_error 'And once you have that, remove the core.bare setting and replace it with core.worktree=$HOME'
  _log_error "(This lets my (modified) bat work with my custom j jumping script)"
  _log_error 'GIT_DIR=$BASH_IT_DOTFILES_GIT_REPO (git config --unset core.bare; git config --add core.worktree "$HOME")'
  return
fi

_log_debug "found dotfiles repository at ${BASH_IT_DOTFILES_GIT_REPO}"
alias config='GIT_DIR="${BASH_IT_DOTFILES_GIT_REPO}" git'

if [ "no" != "$(config config status.showUntrackedFiles)" ] ; then
  _log_error "config dotfiles repo is not configured to hide untracked files - this is very likely to be a huge performance burden"
  _log_error "Try 'config config --local status.showUntrackedFiles no' to set this"
fi

if ! config config core.worktree &>/dev/null ; then
  # libgit2 doesn't support GIT_WORK_TREE, but it does support core.worktree. I'd prefer to use
  # GIT_WORK_TREE, but since bat uses libgit2's rust bindings, *it* doesn't support GIT_WORK_TREE.
  # And therefore I ultimately don't get git integration unless we do it this way
  _log_error "Please set core.worktree to the proper location (probably \$HOME)"
  _log_error 'config config --unset core.bare; config config --add core.worktree "$HOME"'
fi
