# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"
function local_setup_file() {
  echo >&3 "# alias test local setup files start"
  setup_libs "helpers"
  # Load something, anything...
  load ../../completion/available/capistrano.completion
  echo >&3 "# alias test local setup files end"
}

@test "alias-completion: See that aliases with double quotes and brackets do not break the plugin" {
  alias gtest="git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
  echo >&3 "# double quote alias test header"
  run load "${BASH_IT?}/completion/available/aliases.completion.bash" 3>&-
  echo >&3 "# double quote alias test footer"

  assert_success
  echo >&3 "# double quote alias test success"
}

@test "alias-completion: See that aliases with single quotes and brackets do not break the plugin" {
  alias gtest='git log --graph --pretty=format:"%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset" --abbrev-commit --date=relative'
  echo >&3 "# single quote alias test footer"
  run load "${BASH_IT?}/completion/available/aliases.completion.bash" 3>&-
  echo >&3 "# single quote alias test footer"

  assert_success
  echo >&3 "# single quote alias test success"
}

@test "alias-completion: See that having aliased rm command does not output unnecessary output" {
  alias rm='rm -v'
  echo >&3 "# rm alias test header"
  run load "${BASH_IT?}/completion/available/aliases.completion.bash" 3>&-
  echo >&3 "# rm alias test footer"

  refute_output
  echo >&3 "# rm alias test success"
}
