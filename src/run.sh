#!/usr/bin/env bash
set -e

# Don't need initialize container more than 1 times
if [[ -n $SYNC_INIT ]]; then
	exit 0
fi

. "$(pwd)/function.sh"