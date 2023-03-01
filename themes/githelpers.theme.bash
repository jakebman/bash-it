# shellcheck shell=bash

function _git-symbolic-ref() {
	git symbolic-ref -q HEAD 2> /dev/null
}

# When on a branch, this is often the same as _git-commit-description,
# but this can be different when two branches are pointing to the
# same commit. _git-branch is used to explicitly choose the checked-out
# branch.
function _git-branch() {
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		if [[ -n "${VCS_STATUS_LOCAL_BRANCH:-}" ]]; then
			echo "${VCS_STATUS_LOCAL_BRANCH}"
		else
			return 1
		fi
	else
		git symbolic-ref -q --short HEAD 2> /dev/null || return 1
	fi
}

function _git-tag() {
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		if [[ -n "${VCS_STATUS_TAG:-}" ]]; then
			echo "${VCS_STATUS_TAG}"
		fi
	else
		git describe --tags --exact-match 2> /dev/null
	fi
}

function _git-commit-description() {
	git describe --contains --all 2> /dev/null
}

function _git-short-sha() {
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		echo "${VCS_STATUS_COMMIT:0:7}"
	else
		git rev-parse --short HEAD
	fi
}

# Try the checked-out branch first to avoid collision with branches pointing to the same ref.
function _git-friendly-ref() {
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		_git-branch || _git-tag || _git-short-sha # there is no tag based describe output in gitstatus
	else
		_git-branch || _git-tag || _git-commit-description || _git-short-sha
	fi
}

function _git-num-remotes() {
	git remote | wc -l
}

function _git-upstream() {
	local ref
	ref="$(_git-symbolic-ref)" || return 1
	git for-each-ref --format="%(upstream:short)" "${ref}"
}

function _git-upstream-remote() {
	local upstream branch
	upstream="$(_git-upstream)" || return 1

	branch="$(_git-upstream-branch)" || return 1
	echo "${upstream%"/${branch}"}"
}

function _git-upstream-branch() {
	local ref
	ref="$(_git-symbolic-ref)" || return 1

	# git versions < 2.13.0 do not support "strip" for upstream format
	# regex replacement gives the wrong result for any remotes with slashes in the name,
	# so only use when the strip format fails.
	git for-each-ref --format="%(upstream:strip=3)" "${ref}" 2> /dev/null || git for-each-ref --format="%(upstream)" "${ref}" | sed -e "s/.*\/.*\/.*\///"
}

function _git-upstream-behind-ahead() {
	git rev-list --left-right --count "$(_git-upstream)...HEAD" 2> /dev/null
}

function _git-upstream-branch-gone() {
	[[ "$(git status -s -b | sed -e 's/.* //')" == "[gone]" ]]
}

function _git-hide-status() {
	# The original code takes between 0.2 seconds and 0.4 seconds in windows directories
	# I'm simplifying my version of this to just never hide status
	# -Jake
	return 1
}

function _git-status() {
	local git_status_flags=
	if [[ "${SCM_GIT_IGNORE_UNTRACKED:-}" == "true" ]]; then
		git_status_flags='-uno'
	fi
	git status --porcelain "${git_status_flags:---}" 2> /dev/null
}
# Optimized use case - uses gitstatus if possible
# succeeds if _git-status would return any output
# fails otherwise
# Heads up: this is vulnerable to gitstatus's -m (max_dirty/--dirty-max-index-size) setting. Uncertain whether "I dunno" should mean clean, dirty, or take slow git path. Currently, it is taken as 'dirty'
function _git-status-is-dirty() {
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		# A series of yes/no answers encoded as 1/0 strings
		# VCS_STATUS_HAS_UNSTAGED and _UNTRACKED can return -1 for "didn't check"
		# For now, we'll consider that to be identical to "is dirty"
		local git_status
		if [[ "${SCM_GIT_IGNORE_UNTRACKED:-}" == "true" ]]; then
			git_status="${VCS_STATUS_HAS_STAGED}${VCS_STATUS_HAS_CONFLICTED}${VCS_STATUS_HAS_UNSTAGED}"
		else
			git_status="${VCS_STATUS_HAS_STAGED}${VCS_STATUS_HAS_CONFLICTED}${VCS_STATUS_HAS_UNSTAGED}${VCS_STATUS_HAS_UNTRACKED}"
		fi
		case "$git_status" in
			*1*)
				return 0 # found a status-like fact
				;;
			*)
				return 1 # failed to find a status-like fact
				;;
		esac
	fi # fast path done
	# TODO: wish there were a way to notify the user which path was used - fast or slow
	[[ -n "$(_git-status | tail -n1)" ]]
}

function _git-status-counts() {
	_git-status | awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]. .+/) {
        staged += 1
      }
    }
  }
  END {
    print untracked "\t" unstaged "\t" staged
  }'
}

function _git-remote-info() {
	local same_branch_name="" branch_prefix
	# prompt handling only, reimplement because patching the routine below gets ugly
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		[[ "${VCS_STATUS_REMOTE_NAME?}" == "" ]] && return
		[[ "${VCS_STATUS_LOCAL_BRANCH?}" == "${VCS_STATUS_REMOTE_BRANCH?}" ]] && same_branch_name=true
		# no multiple remote support in gitstatusd
		if [[ "${SCM_GIT_SHOW_REMOTE_INFO:-}" == "true" || "${SCM_GIT_SHOW_REMOTE_INFO:-}" == "auto" ]]; then
			if [[ ${same_branch_name:-} != "true" ]]; then
				remote_info="${VCS_STATUS_REMOTE_NAME?}/${VCS_STATUS_REMOTE_BRANCH?}"
			else
				remote_info="${VCS_STATUS_REMOTE_NAME?}"
			fi
		elif [[ ${same_branch_name:-} != "true" ]]; then
			remote_info="${VCS_STATUS_REMOTE_BRANCH?}"
		fi
		if [[ -n "${remote_info:-}" ]]; then
			# no support for gone remote branches in gitstatusd
			branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX:-}"
			echo "${branch_prefix}${remote_info:-}"
		fi
	else
		[[ "$(_git-upstream)" == "" ]] && return

		[[ "$(_git-branch)" == "$(_git-upstream-branch)" ]] && same_branch_name=true
		if [[ ("${SCM_GIT_SHOW_REMOTE_INFO}" == "auto" && "$(_git-num-remotes)" -ge 2) ||
		"${SCM_GIT_SHOW_REMOTE_INFO}" == "true" ]]; then
			if [[ ${same_branch_name:-} != "true" ]]; then
				# shellcheck disable=SC2016
				remote_info='$(_git-upstream)'
			else
				remote_info="$(_git-upstream-remote)"
			fi
		elif [[ ${same_branch_name:-} != "true" ]]; then
			# shellcheck disable=SC2016
			remote_info='$(_git-upstream-branch)'
		fi
		if [[ -n "${remote_info:-}" ]]; then
			local branch_prefix
			if _git-upstream-branch-gone; then
				branch_prefix="${SCM_THEME_BRANCH_GONE_PREFIX:-}"
			else
				branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX:-}"
			fi
			echo "${branch_prefix}${remote_info:-}"
		fi
	fi
}
