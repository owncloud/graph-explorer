#!/bin/sh

set -euo pipefail

# Check for parameters, prepend with our exe when the first arg is a parameter.
if [ "${1:0:1}" = '-' ]; then
	set -- ${EXE} caddy "$@"
else
	# Check for some basic commands, this is used to allow easy calling without
	# having to prepend the binary all the time.
	case "${1}" in
		serve)
			shift
			exec 1>/dev/null
			set -- ${EXE} caddy "$@"
			;;
		caddy)
			set -- ${EXE} "$@"
			;;
	esac
fi

# Setup environment.
setup_env() {
	[ -f /etc/defaults/docker-env ] && source /etc/defaults/docker-env

	[ ! -e /tmp/secrets ] && cp -vf secrets.sample.js /tmp/secrets.js
	sed -i -r "s|(window.ClientId = )(.*)|\1\"$GRAPI_EXPLORER_CLIENT_ID\";|g" /tmp/secrets.js
	cat /tmp/secrets.js

	[ ! -e /tmp/config.js ] && cp -vf config.sample.js /tmp/config.js
	sed -i -r "s|(window.Iss = )(.*)|\1\"$GRAPI_EXPLORER_ISS\";|g" /tmp/config.js
	sed -i -r "s|(window.GraphUrl = )(.*)|\1\"$GRAPI_EXPLORER_GRAPH_URL\";|g" /tmp/config.js
	cat /tmp/config.js
}
setup_env

# Support additional args provided via environment.
if [ -n "${ARGS}" ]; then
	set -- "$@" ${ARGS}
fi

exec "$@"