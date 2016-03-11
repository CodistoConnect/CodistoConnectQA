#!/bin/bash

#Determines if stashing current state before pull or checking out a specific SHA occurs followed by popping after the action is completed
STASHPOP=$1

#The specific SHA1 hash of the commit to checkout
SHA1=$2

PLUGINPATH=${HOME}/approot/CodistoConnect

cd ${PLUGINPATH}

#If caller wants to save current state, stash then pop do so
if [ -n ${STASHPOP} ]; then
        git stash >/dev/null 2>&1
fi

#Make sure all remotes are up to date before we pull or checkout SHA's which might not exist
git fetch --all --prune >/dev/null 2>&1

#Pull specific SHA1 - This is ideal for web hook receive - you can redeliver a packet and it will checkout correct SHA and create correct tag etc
logger -s "Checking out commit ${SHA1}"
git checkout "${SHA1}" --force >/dev/null 2>&1

if [ -n "${STASHPOP}" ]; then
        git stash pop >/dev/null 2>&1
fi
