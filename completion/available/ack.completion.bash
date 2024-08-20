# Bash completion for ack:
# ack <tab>
#
# Github: https://github.com/jonasbn/bash_completion_ack
# Copyright Jonas B. Nielsen (jonasbn) 2017
# Extentions Copyright Robert P. Goldman (rpgoldman) and SIFT, LLC (siftech) 2022
# MIT License
# added to Jake's bash-it from https://github.com/jonasbn/bash_completion_ack/raw/9f387108a813b7e214b47e4e269392ae89217e82/ack
# and modified since then, to reduce perl calls for _acktypeargs and _negacktypes
# for a .5s speedup on WSL startup

_acktypes=( $(ack --help-types | tail +10 | awk '{gsub(/^[ \t]+/,"",$1); print$1;}') )
_acktypeargs=()
_negacktypes=()
for arg in "${_acktypes[@]}"; do
	_acktypeargs+=("--$arg")
	_negacktypes+=("no$arg")
done

_ack()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    local opts="${_acktypeargs[@]}"
    # File select actions:
    opts+=" -f -g -l"
    # File listing actions
    opts+=" --files-with-matches -L --files-without-matches -c --count"
    # Searching
    opts+=" -i --ignore-case -S --smart-case --nosmart-case -I --no-ignore-case -v --invert-match -w --word-regexp"
    opts+=" -Q --literal"
    opts+=" --range-start --range-end --match"
    # Search output
    opts+=" --output -o --passthru -1 -H --with-filename -h --no-filename --column --nocolumn --print0"
    opts+=" -A --after-context -B --before-context -C --context"
    # File presentation
    opts+=" -s --pager --nopager --heading --noheading --break --nobreak --group --nogroup -p --proximate --underline --nounderline"
    opts+=" --nocolor --color --help-colors --help-rgb-colors --flush"
    opts+=" --color-filename --color-match --color-colno --color-lineno"
    # File finding
    opts+=" --sort-files --show-types -x"
    # File inclusion/exclusion:
    opts+=" --ignore-dir --noignore-dir --ignore-directory --noignore-directory --ignore-file"
    opts+="-r -R --recurse -n --no-recurse --follow --nofollow"
    # File type inclusion/exclusion:
    opts+=" -k --known-types --help-types --type -t -T"
    # miscellaneous args
    opts+=" --version --env --noenv --dump --filter --nofilter --help --man"
    opts+=" --thpppt --bar --cathy"

    case $prev in
        # searching commands require patterns, count arguments require numbers
        -m | --max-count | -A | --after-context | \
            -B | --before-context | -C | --context | \
            -p | --proximate | \
            --range-start | --range-end | -match | --output | \
            --pager | \
            --color-filename | --color-match | --color-colno | --color-lineno | \
            --ignore-file | \
            --type-set | --type-add | --type-del)
            # argument required but no completions available
            return
            ;;
        --files-from )
            COMPREPLY=($(compgen -f))
            return
            ;;
        --ignore-dir | --noignore-dir | --ignore-directory | --noignore-directory )
            COMPREPLY=($(compgen -d))
            return
            ;;
        -t | -T)
            COMPREPLY=( "${_acktypes[@]}" ) # direct copy acktypes
            return
            ;;
        --type)
            COMPREPLY=( "${_acktypes[@]}" )
            COMPREPLY+=( "${_negacktypes[@]}" )
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    else
        compopt -o default
    fi
}

complete -o default -F _ack ack
