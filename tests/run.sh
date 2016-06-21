#!/usr/bin/env bash
#set -x

. "$(pwd)/src/function.sh"

# === Common test cases ===

# $1 is function name
assert()
{
    if $1 &> /dev/null; then
        return 0
    fi

    return 127
}

# $1 is function name
against()
{
    if assert $1; then
        return 127
    fi

    return 0
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
    return $(against existUser)
}

testExistedUser()
{
    local SYNC_USER="root" # Root user usually exist with any linux-based image
    return $(against existUser)
}

testNotExistedUser()
{
    local SYNC_USER="dockersyncer"  # User with it name usually not exist in linux-based image
    return $(assert existUser)
}

testUser()
{
    if testNotSpecifyUser && testExistedUser && testNotExistedUser; then
        successMessage existUser
    else
        failMessage existUser
    fi

    return $?
}

# === The UID test cases ===

testNotSpecifyUID()
{
    return $(assert existUID)
}

testExistedUID()
{
    local SYNC_UID=0 # UID is 0 usually assign in root user
    return $(against existUID)
}

testNotExistedUID()
{
    local SYNC_UID=1011 # Random UID not existing with test container
    return $(assert existUID)
}

testUID()
{
    if testNotSpecifyUID && testExistedUID && testNotExistedUID; then
        successMessage existUID
    else
        failMessage existUID
    fi

    return $?
}

# === Run all tests

testUser
testUID