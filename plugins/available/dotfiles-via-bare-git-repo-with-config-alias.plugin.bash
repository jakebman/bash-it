
# One of the options described in https://news.ycombinator.com/item?id=11070797
# at https://news.ycombinator.com/item?id=11070797
about-plugin "Following the ideas at https://www.atlassian.com/git/tutorials/dotfiles"

# Convention is that a bare git repo has a .git suffix
: "${BASH_IT_DOTFILES_GIT_REPO:=~/.dotfiles-repo.git}"

if ! [ -d "${BASH_IT_DOTFILES_GIT_REPO}" ] ; then
  _log_error "${BASH_IT_DOTFILES_GIT_REPO} (\${BASH_IT_DOTFILES_GIT_REPO}) is not a valid git dir."
  _log_error "Try 'git init --bare \${BASH_IT_DOTFILES_GIT_REPO}' to create it,"
  _log_error "Or 'git clone \${YOUR_GIT_URL} --bare {BASH_IT_DOTFILES_GIT_REPO}' to get it from somewhere else"
  _log_error "or set BASH_IT_DOTFILES_GIT_REPO to your bare git directory"
  return
fi

_log_debug "found dotfiles repository at ${BASH_IT_DOTFILES_GIT_REPO}"
alias config='git --git-dir="${BASH_IT_DOTFILES_GIT_REPO}" --work-tree="$HOME"'

if [ "no" != "$(config config status.showUntrackedFiles)" ] ; then
  _log_error "config dotfiles repo is not configured to hide untracked files - this is very likely to be a huge performance burden"
  _log_error "Try 'config config --local status.showUntrackedFiles no' to set this"
fi
