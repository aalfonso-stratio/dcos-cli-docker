#!/bin/bash

set -e

touch /dcos/dcos-cli-setup.log

echo "Initial dcos-cli setup:" >> /dcos/dcos-cli-setup.log
if [[ ! -z ${DCOS_URL} ]]; then
	dcos config set core.dcos_url ${DCOS_URL} > /dcos/dcos-cli-setup.log 
fi

if [[ ! -z ${DCOS_ACS_TOKEN} ]]; then
	dcos config set core.dcos_acs_token ${DCOS_ACS_TOKEN} > /dcos/dcos-cli-setup.log
fi

if [[ ! -z ${EMAIL} ]]; then
	dcos config set core.email ${EMAIL} > /dcos/dcos-cli-setup.log
fi

if [[ ! -z ${MESOS_MASTER_URL} ]]; then
	dcos config set core.mesos_master_url ${MESOS_MASTER_URL} > /dcos/dcos-cli-setup.log
fi

if [[ ! -z ${TOKEN} ]]; then 
	dcos config set core.token ${TOKEN} > /dcos/dcos-cli-setup.log
fi

dcos config set core.reporting ${CORE_REPORTING:-true} > /dcos/dcos-cli-setup.log
dcos config set core.ssl_verify ${SSL_VERIFY:-false} > /dcos/dcos-cli-setup.log
dcos config set core.timeout ${TIMEOUT:-5} > /dcos/dcos-cli-setup.log

if [[ "${TOKEN_AUTHENTICATION}" == "true" ]]; then
	token=$(phantomjs --ignore-ssl-errors=yes dcosToken.js "${DCOS_URL}" ${DCOS_USER} "${DCOS_PASSWORD}")
	echo $token | dcos marathon task list
fi

if [[ "${SSH}" == "true" ]]; then
        /usr/sbin/sshd -D -e
fi

tail -f /dcos/dcos-cli-setup.log
