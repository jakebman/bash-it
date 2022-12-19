cite about-plugin
about-plugin 'Load Software Development Kit Manager'

# Use $SDKMAN_DIR if defined,
# otherwise default to ~/.sdkman
export SDKMAN_DIR=${SDKMAN_DIR:-$HOME/.sdkman}

if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
	source "${SDKMAN_DIR}/bin/sdkman-init.sh"
else
	_log_error "please install SDKMAN - 'curl https://get.sdkman.io | bash' or read more at https://sdkman.io"
fi
