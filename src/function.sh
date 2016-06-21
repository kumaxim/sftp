#!/usr/bin/env bash
set -e

# SYNC_USER
# SYNC_PASSWORD
# SYNC_UID
# SYNC_GROUP
# SYNC_GID
# SYNC_SOURCE_DIR
# SYNC_DESTINATION_DIR

# docker run -v /path/in/home/folder:/tmp/some_dir
        # -e SYNC_SOURCE_DIR="/tmp/some_dir"
        # -e SYNC_DESTINATION_DIR="/var/www"
        # -v /var/www
        
existUser()
{
    if [[ -z $SYNC_USER ]]; then
        echo "FATAL ERROR: You must specify \"SYNC_USER\" environment variable"
        return 1
    fi

    if [[ -n $(getent passwd $SYNC_USER) ]]; then
        echo "FATAL ERROR: User \"$SYNC_USER\" already exist in container"
        return 1
    fi

    return 0
}

existUID()
{
    if [[ -z $SYNC_UID ]]; then
        return 0
    else
        if [[ -n $(getent passwd $SYNC_UID) ]]; then
            user_wth_uid=$(getent passwd $SYNC_UID | cut -d : -f1)
            echo "FATAL ERROR: User \"$user_wth_uid\" already have the UID \"$SYNC_UID\""
            return 1
        fi
    fi

    return 0
}

existGroup()
{
    return 0
}

existGID()
{
    return 0
}
