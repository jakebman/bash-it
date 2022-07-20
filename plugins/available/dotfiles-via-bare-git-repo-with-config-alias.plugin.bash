
# One of the options described in https://news.ycombinator.com/item?id=11070797
# at https://news.ycombinator.com/item?id=11070797
about-plugin "Following the ideas at https://www.atlassian.com/git/tutorials/dotfiles"

# Convention is that a bare git repo has a .git suffix
: "${BASH_IT_DOTFILES_GIT_REPO:=~/.cfg.git}"

if ! [ -d "${BASH_IT_DOTFILES_GIT_REPO}" ] ; then
  _log_error "${BASH_IT_DOTFILES_GIT_REPO} is not a valid git dir."
  _log_error "Try 'git init --bare ${BASH_IT_DOTFILES_GIT_REPO}' to create it,"
  _log_error "or set BASH_IT_DOTFILES_GIT_REPO to your bare git directory"
  return
fi

_log_debug "found dotfiles repository at ${BASH_IT_DOTFILES_GIT_REPO}"
alias config='/usr/bin/git --git-dir="${BASH_IT_DOTFILES_GIT_REPO}" --work-tree="$HOME"'
config config --local status.showUntrackedFiles no
