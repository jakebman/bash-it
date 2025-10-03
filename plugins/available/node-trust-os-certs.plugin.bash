# shellcheck shell=bash
cite about-plugin
about-plugin 'Configure Node.js to also trust the OS-level certificates (via NODE_EXTRA_CA_CERTS)'

# This is needed for (at least) the postman CLI

# TODO: does --use-system-ca work? If so, NODE_OPTIONS+=" --use-system-ca " would be nice
# ... eve though this isn't in https://nodejs.org/api/cli.html#node_optionsoptions :(
# https://nodejs.org/api/cli.html#--use-system-ca

function _node_search_ca_certs {
	local candidate

	# List from https://go.dev/src/crypto/x509/root_linux.go, suggested by:
	# https://serverfault.com/questions/62496/ssl-certificate-location-on-unix-linux
	for candidate in \
		/etc/ssl/certs/ca-certificates.crt \
		/etc/pki/tls/certs/ca-bundle.crt \
		/etc/ssl/ca-bundle.pem \
		/etc/pki/tls/cacert.pem \
		/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
		/etc/ssl/cert.pem; do

		if [ -f "$candidate" ]; then
			# see https://nodejs.org/api/cli.html#cli_node_extra_ca_certs_file
			export NODE_EXTRA_CA_CERTS=$candidate
			return
		fi
	done
}

_node_search_ca_certs
