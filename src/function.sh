#!/bin/bash

# SYNC_USER
# SYNC_PASSWORD
# SYNC_UID
# SYNC_GROUP
# SYNC_GID
# SYNC_FOLDER
# SYNC_MODE

# docker run -v /path/in/home/folder:/tmp/some_dir
        # -e SYNC_FOLDER="/var/www/some_dir"
        # -v /var/www/some_dir
        
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
    fi

    if [[ -n $(getent passwd $SYNC_UID) ]]; then
        local existedUser=$(getent passwd $SYNC_UID | cut -d : -f1)
        echo "FATAL ERROR: User \"$existedUser\" already have the UID \"$SYNC_UID\""
        return 1
    fi

    return 0
}

existGroup()
{
    if [[ -z $SYNC_GROUP ]]; then
        # Group name will be the same as username
        return 0
    fi

    if [[ -n $SYNC_GROUP ]]; then
        if [[ -n $(getent group $SYNC_GROUP) ]]; then
            echo "FATAL ERROR: Group \"$SYNC_GROUP\" already exist in container"
            return 1
        fi
    fi

    return 0
}

existGID()
{
     if [[ -z $SYNC_GID ]]; then
        return 0
    fi

    if [[ -n $(getent group $SYNC_GID) ]]; then
        local existedGroup=$(getent group $SYNC_GID | cut -d : -f1)
        echo "FATAL ERROR: Group \"$existedGroup\" already have the GID \"$SYNC_GID\""
        return 1
    fi

    return 0
}

nonRootFolder()
{
    if [[ -z $SYNC_FOLDER ]]; then
        echo "FATAL ERROR: You must specify \"$SYNC_FOLDER\" environment variable"
        return 1
    fi

    if [[ $(dirname $SYNC_FOLDER) == "/" || $(basename $SYNC_FOLDER) == "/" || pwd == "/" ]]; then
        echo "FATAL ERROR: Root folder can not be home directory for user"
        return 1
    fi

    return 0
}

allowSyncMode()
{
    if [[ $SYNC_MODE == "update" || $SYNC_MODE == "overwrite" ]]; then
        return 0
    fi

    echo "FATAL ERROR: Environment variable \"SYNC_MODE\" can have only \"update\" or \"overwrite\" value"
    return 1
}
