#!/bin/bash

# SYNC_USER
# SYNC_UID
# USER_PASSWORD
# USER_HOME_DIRECTORY
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

userPassword()
{
    if [[ -z $USER_PASSWORD ]]; then
        echo "FATAL ERROR: You must specify \"USER_PASSWORD\" environment variable"
        return 1
    fi

    # TODO: add validating rules in v.2

    return 0
}

userHomeDirNoRoot()
{
    if [[ -z $USER_HOME_DIRECTORY ]]; then
        echo "FATAL ERROR: You must specify \"USER_HOME_DIRECTORY\" environment variable"
        return 1
    fi

    if [[ $USER_HOME_DIRECTORY == "/" ]]; then
        echo "FATAL ERROR: User home directory can not be the root"
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
        echo "FATAL ERROR: User \"$existedUser\" already have the SYNC_UID \"$SYNC_UID\""
        return 1
    fi

    return 0
}

existGroup()
{
    if [[ -z $SYNC_GROUP ]]; then
        # SYNC_GROUP name will be the same as SYNC_USERname
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
        echo "FATAL ERROR: Group \"$existedGroup\" already have the SYNC_GID \"$SYNC_GID\""
        return 1
    fi

    return 0
}

syncFolderInsideHomeDir()
{
    if [[ -z $SYNC_FOLDER ]]; then
        echo "FATAL ERROR: You must specify \"SYNC_FOLDER\" environment variable"
        return 1
    fi

    if [[ $(dirname $SYNC_FOLDER) == $USER_HOME_DIRECTORY ]]; then
        
        return 0
    fi

    echo "FATAL ERROR: Forlder for synchronization must be place inside \"$USER_HOME_DIRECTORY\""
    return 1
}

allowSyncMode()
{
    # Variable can be empty. This means than will use update mode
    if [[ -z $SYNC_MODE || $SYNC_MODE == "update" || $SYNC_MODE == "overwrite" ]]; then
        return 0
    fi

    echo "FATAL ERROR: Environment variable \"SYNC_MODE\" can have only \"update\" or \"overwrite\" value"
    return 1
}
