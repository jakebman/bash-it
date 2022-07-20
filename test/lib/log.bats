# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
  setup_libs "log"
}

# This might not be the right way to test this
function _bash-it-timestamp() {
  echo "(A timestamp goes here)"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ALL" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_debug "test test test"
  assert_output "$(_bash-it-timestamp)DEBUG: default: test test test"
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ALL" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_warning "test test test"
  assert_output "$(_bash-it-timestamp) WARN: default: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ALL" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_error "test test test"
  assert_output "$(_bash-it-timestamp)ERROR: default: test test test"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_WARNING" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_WARNING" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_warning "test test test"
  assert_output "$(_bash-it-timestamp) WARN: default: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_WARNING" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_error "test test test"
  assert_output "$(_bash-it-timestamp)ERROR: default: test test test"
}


@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ERROR" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_error "test test test"
  assert_output "$(_bash-it-timestamp)ERROR: default: test test test"
}

@test "lib log: basic debug silent logging" {
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning silent logging" {
  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error silent logging" {
  run _log_error "test test test"
  refute_output
}

@test "lib log: logging with prefix" {
  export -f _bash-it-timestamp # mock the timestamp
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  BASH_IT_LOG_PREFIX="nice: prefix: "
  run _log_debug "test test test"
  assert_output "$(_bash-it-timestamp)DEBUG: nice: prefix: test test test"
}
