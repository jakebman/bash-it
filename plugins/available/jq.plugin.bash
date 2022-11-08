#! /bin/bash

function _jq-ify {
  # TODO: try and actually respect the parameter orders of our parameters
  # and figure out which is actually supposed to be the argument files
  about "use \$JQ_FILTER to choose a smaller section of the files to compare!"
  local cmd="$1"
  local left="$2"
  local right="$3"
  local filter="${JQ_FILTER:-.}"
  shift 3
  "$cmd" "$@" <(jq -S "$filter" <"$left") <(jq -S "$filter" <"$right")
}

alias jqdiff="_jq-ify diff"
alias jqvimdiff="_jq-ify vimdiff"
