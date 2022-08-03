#! /bin/bash

function _jq-ify {
  # TODO: try and actually respect the parameter orders of our parameters
  # and figure out which is actually supposed to be the argument files
  local cmd="$1"
  local left="$2"
  local right="$3"
  shift 3
  "$cmd" "$@" <(jq -S . <"$left") <(jq -S . <"$right")
}

alias jqdiff="_jq-ify diff"
alias jqvimdiff="_jq-ify vimdiff"
