#!/usr/bin/env bash
set -e

# Don't need initialize container more than 1 times
if [[ -n $SYNC_INIT ]]; then
	exit 0
fi

# SYNC_USER
# USER_PASSWORD
# USER_HOME_DIRECTORY
# SYNC_UID
# SYNC_GROUP
# SYNC_GID
# SYNC_FOLDER
# SYNC_MODE

. "$(pwd)/function.sh"