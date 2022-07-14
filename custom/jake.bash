
# the commonly-known env variables for common tools
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# Allow less to simply dump the output to STDOUT when it would all fit on a single page
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager
# no-init disables that weird 'second screen' behavior, which I don't like
# RAW... enables color interpretation
# quit-at-eof gives you the change to scroll to the end, but if you keep
#   scrolling it also exits (I like not feeling trapped)
export LESS="--quit-if-one-screen --quit-at-eof --no-init --RAW-CONTROL-CHARS"

if _command_exists pygmentize ; then
  # see `man less`, section "INPUT PREPROCESSOR"
  # TODO: when using less as ack's pager, this error occurs:
  #  # Error: cannot read infile: [Errno 2] No such file or directory: '-'
  # because pygmentize doesn't follow the convention that - is stdin (they use the absence of arguments to communicate that)
  # Adding the second '|' to the front of this command and piping errors to a temp file is a way
  # to silently ignore this error, but it'd be really cool to teach pygmentize to recognize
  # '-' as an input file
  export  LESSOPEN='||- pygmentize -f 256 -O style="${LESSSTYLE:-default}" -g %s 2>/tmp/pygmentize-errors'
else
  _log_error "pygmentize is available via sudo apt install python-pygments"
fi

function vars {
  if [ "$#" -eq 0 ] ; then
    # magic incantation from the internet
    # Basically, prints the variables and functions of
    # the current bash session, but doesn't print the functions
    (set -o posix; set)
  else
     (set -o posix; set) | grep "$@"
  fi
}
alias var=vars # because I'm lazy

function update-ack-and-its-manpages {
  local bin_dir="${HOME}/bin"
  local man_dir="${bin_dir}/man"
  # I'm learning about manpages, so this first implementation is likely bad
  mkdir -p "${man_dir}/man1" # ack's manpage goes in man1. Add others here as needed

  # instructions from https://beyondgrep.com/install/
  # I wish they had a -latest option.
  if ! curl https://beyondgrep.com/ack-v3.5.0 > "${bin_dir}/ack" && chmod 0755 "${bin_dir}/ack" ; then
    echo "failed"
    return 1
  fi

  echo # spacing

  # set up the manpath within ~/bin; I don't want to have to maintain ~/man
  if grep "$man_dir" "${HOME}/.manpath" &>/dev/null ; then
    echo "your user-specific manpath config already knows about ${man_dir}. Woohoo!"
  else
    echo "adding a section to your ~/.manpath file that looks like this:"
    cat <<END | tee --append "${HOME}/.manpath"
# this section was added automatically by my ackrc-creation script. I really hope it didn't break anything
# -Jake Boeckerman
MANDATORY_MANPATH ${man_dir}
MANPATH_MAP ${bin_dir} ${man_dir}
END
  fi

  echo # spacing

  if _command_exists pod2man ; then
    local manfile="${man_dir}/man1/ack.1p"
    pod2man ~/bin/ack >$manfile
    echo "manfile created at ${manfile}. It looks like:"
    ls -l "$manfile"
  else
    echo "please install pod2man. Probably via apt install perl"
    return 1
  fi

  echo # spacing

  if _command_exists mandb ; then
    mandb --user-db || return 1
    echo # spacing
    echo mandb user db updated
  else
    echo "please install mandb. Otherwise, this won't work"
    return 1
  fi
}

function jake_debug {
	echo `date +"%r"` "$@" >>~/jake-bashit-debug
}
