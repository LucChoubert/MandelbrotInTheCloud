#!/bin/bash

# From: https://www.linuxjournal.com/content/add-binary-payload-your-shell-scripts

SCRIPT_PATH=$(dirname "${BASH_SOURCE}")

# Check for payload format option (default is base64).
base64=1
if [[ "$1" == '--binary' ]]; then
	binary=1
	base64=0
	shift
fi
if [[ "$1" == '--base64' ]]; then
	binary=0
	base64=1
	shift
fi

if [[ ! "$1" ]]; then
	echo "Usage: $0 [--binary | --base64] PAYLOAD_FILE"
	exit 1
fi

# Clean output file
rm -f ${SCRIPT_PATH}/install.sh

if [[ $binary -ne 0 ]]; then
	# Append binary data.
	sed \
		-e 's/base64=./base64=0/' \
		-e 's/binary=./binary=1/' \
			 ${SCRIPT_PATH}/install.sh.in > ${SCRIPT_PATH}/install.sh
	echo "PAYLOAD:" >> ${SCRIPT_PATH}/install.sh

	cat $1 >> ${SCRIPT_PATH}/install.sh
fi
if [[ $base64 -ne 0 ]]; then
	# Append base64d data.
	sed \
		-e 's/base64=./base64=1/' \
		-e 's/binary=./binary=0/' \
			 ${SCRIPT_PATH}/install.sh.in > ${SCRIPT_PATH}/install.sh
	echo "PAYLOAD:" >> ${SCRIPT_PATH}/install.sh

	cat $1 | base64 - >> ${SCRIPT_PATH}/install.sh
fi
