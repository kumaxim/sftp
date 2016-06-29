#!/bin/bash
# set -x
set -o pipefail

. "$(pwd)/src/function.sh"

# === Common test cases ===

# Success if return code is zero. Fail otherwise
assert()
{
    if [[ $1 == 0 ]]; then
        return 0
    fi

    return 127
}

# Success if return code is non-zero. Fail othrwise
against()
{
    return $(assert $1 && echo 127 || echo 0)
}

# Print message about success. $1 is name test case
successMessage()
{
    echo "TEST: The function \"$1\" works correctly"
    return 0
}

# Print message about fail. $1 is name test case
failMessage()
{
    echo "TEST: The function \"$1\" returned with ERROR code"
    return 127
}

# === The username test cases ===

testNotSpecifyUser()
{
    against $(existUser > /dev/null; echo $?)
    return $?
}

testExistedUser()
{
    local SYNC_USER="root" # Root user usually exist with any linux-based image
    
    against $(existUser > /dev/null; echo $?)
    return $?
}

testNotExistedUser()
{
    local SYNC_USER="dockersyncer"  # User with it name usually not exist in linux-based image
    
    assert $(existUser > /dev/null; echo $?)
    return $?
}

testUser()
{
    unset SYNC_USER # Reset the tests variable

    if testNotSpecifyUser && testExistedUser && testNotExistedUser; then
        successMessage "existUser"
        return $?
    fi

    failMessage "existUser"
    return $?
}

# === The user password test cases ===

testUserPasswordNotSpecify()
{
    against $(userPassword > /dev/null; echo $?)
    return $?
}

testUserPasswordExist()
{
    local USER_PASSWORD="password_phrase"
    assert $(userPassword > /dev/null; echo $?)
    return $?
}

testUserPassword()
{
    unset USER_PASSWORD # Reset the tests variable

    if testUserPasswordNotSpecify && testUserPasswordExist; then
        successMessage "userPassword"
        return $?
    fi

    failMessage "userPassword"
    return $?
}

# === The user home directory test cases ===

testUserHomeDirNotSpecify()
{
    against $(userHomeDirNoRoot > /dev/null; echo $?)
    return $?
}

testUserHomeDirIsRoot()
{
    local USER_HOME_DIRECTORY="/"
    against $(userHomeDirNoRoot > /dev/null; echo $?)

    return $?
}

testUserHomeDirInDeep()
{
    local USER_HOME_DIRECTORY="/home/var/some_dir"

    assert $(userHomeDirNoRoot > /dev/null; echo $?)
    return $?
}

testUserHomeDir()
{
    unset USER_HOME_DIRECTORY # Reset the tests variable

    if testUserHomeDirNotSpecify && testUserHomeDirIsRoot && testUserHomeDirInDeep; then
        successMessage "userHomeDirNoRoot"
        return $?
    fi

    failMessage "userHomeDirNoRoot"
    return $?
}

# === The UID test cases ===

testNotSpecifyUID()
{
    assert $(existUID > /dev/null; echo $?)
    return $?
}

testExistedUID()
{
    local SYNC_UID=0 # UID is 0 usually assign in root user
    against $(existUID > /dev/null; echo $?)
    return $?
}

testNotExistedUID()
{
    local SYNC_UID=1011 # Random UID not existing with test image
    assert $(existUID > /dev/null; echo $?)
    return $?
}

testUID()
{
    unset SYNC_UID # Reset the tests variable

    if testNotSpecifyUID && testExistedUID && testNotExistedUID; then
        successMessage "existUID"
        return $?
    fi

    failMessage "existUID"
    return $?
}

# === The group name test cases ===

testNotSpecifyGroup()
{
    assert $(existGroup > /dev/null; echo $?)
    return $?
}

testExistedGroup()
{
    local SYNC_GROUP="root" # Root user usually exist with any linux-based image
    against $(existGroup > /dev/null; echo $?)
    return $?
}

testNotExistedGroup()
{
    local SYNC_GROUP="dockersyncer"  # User with it name usually not exist in linux-based image
    assert $(existGroup > /dev/null; echo $?)
    return $?
}

testGroup()
{
    unset SYNC_GROUP # Reset the tests variable

    if testNotSpecifyGroup && testExistedGroup && testNotExistedGroup; then
        successMessage "existGroup"
        return $?
    fi

    failMessage "existGroup"
    return $?
}

# === The GID test cases ===

testNotSpecifyGID()
{
    assert $(existGID > /dev/null; echo $?)
    return $?
}

testExistedGID()
{
    local SYNC_GID="0" # GID is zero for the root user
    against $(existGID > /dev/null; echo $?)
    return $?
}

testNotExistedGID()
{
    local SYNC_GID="1011"  # Random GID not existing with test image
    assert $(existGID > /dev/null; echo $?)
    return $?
}


testGID()
{
    unset SYNC_GID # Reset the tests variable

    if testNotSpecifyGID && testExistedGID && testNotExistedGID; then
        successMessage "existGID"
        return $?
    fi

    failMessage "existGID"
    return $?
}

# === The sync folder test cases

testSyncFolderNotSpecify()
{
    against $(syncFolderInsideHomeDir > /dev/null; echo $?)
    return $?
}

testSyncFolderOutsideUserHomeDirectory()
{
    local USER_HOME_DIRECTORY="/home/someUser"
    local SYNC_FOLDER="/var/www/sync_some_data"

    against $(syncFolderInsideHomeDir > /dev/null; echo $?)
    return $?
}

testSyncFolderInsideUserHomeDirectory()
{
    local USER_HOME_DIRECTORY="/var/www"
    local SYNC_FOLDER="/var/www/sync_some_data"

    assert $(syncFolderInsideHomeDir > /dev/null; echo $?)
    return $?
}

testSyncFolder()
{
    unset SYNC_FOLDER # Reset the tests variable

    if testSyncFolderNotSpecify && testSyncFolderOutsideUserHomeDirectory && testSyncFolderInsideUserHomeDirectory; then
        successMessage "syncFolderInsideHomeDir"
        return $?
    fi

    failMessage "syncFolderInsideHomeDir"
    return $?
}

# === The sync mode test cases

testNotSpecifySyncMode()
{
    assert $(allowSyncMode > /dev/null; echo $?)
    return $?
}

testValidSyncMode()
{
    for mode in "update" "overwrite"; do
        local SYNC_MODE=$mode
        assert $(allowSyncMode > /dev/null; echo $?)

        if [[ $? > 0 ]]; then
            return 127
        fi
    done

    return $?
}

testInvalidSyncMode()
{
    local SYNC_MODE="random_mode"

    against $(allowSyncMode > /dev/null; echo $?)
    return $?
}


testSyncMode()
{
    unset SYNC_MODE # Reset the tests variable

    if testNotSpecifySyncMode && testInvalidSyncMode && testValidSyncMode; then
        successMessage "allowSyncMode"
        return $?
    fi

    failMessage "allowSyncMode"
    return $?
}

# === The folder test cases ===



# === Run all tests ===
if testUser && testUserPassword && testUserHomeDir && testUID && testGroup && testGID && 
    testSyncFolder && testSyncMode; then
    echo "STATUS: All tests completed successfully"
    exit 0
fi

echo "STATUS: One of tests completed failure"
exit 1

