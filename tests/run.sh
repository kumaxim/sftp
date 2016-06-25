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

successMessage()
{
    echo "TEST: The function \"$1\" works correctly"
    return 0
}

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
    local SYNC_UID=1011 # Random UID not existing with test container
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

testNotSpecifyGroupAndUsername()
{
    assert $(existGroup > /dev/null; echo $?)
    return $?
}

testNotSpecifyGroup()
{
    against $(existGroup > /dev/null; echo $?)
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
    # Function "existGroup" calling the "existUser" function
    local SYNC_USER="dockersyncer" # Testing with invalid username devoid of meaning

    if testNotSpecifyGroupAndUsername && testNotSpecifyGroup && testExistedGroup && testNotExistedGroup; then
        successMessage "existGroup"
        return $?
    fi

    failMessage "existGroup"
    return $?
}

# === Run all tests ===

testUser
testUID
#testGroup