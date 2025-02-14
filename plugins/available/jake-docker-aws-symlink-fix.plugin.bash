# Docker overwrites my symlinks :(

# https://stackoverflow.com/questions/2405305/how-to-tell-if-a-file-is-git-tracked-by-shell-exit-code
if ! git ls-files --error-unmatch ~/.aws >&/dev/null; then
	_log_debug "git is not tracking ~/.aws - no worries! Feel free to remove this $BASH_SOURCE file"
	return
fi

if [ -n "$(git status --porcelain ~/.aws 2>&1)" ]; then
	_log_warning "~/.aws has been modified! fixing it"
	git restore ~/.aws &>/dev/null
fi
