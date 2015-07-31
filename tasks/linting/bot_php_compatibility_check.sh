#!/bin/bash

PHPVERSION=$1
#Determines if stashing current state before pull or checking out a specific SHA occurs followed by popping after the action is completed
STASHPOP=$2

#The specific SHA1 hash of the commit to checkout
SHA1=$3

PLUGINPATH=$4

if [ -z ${PLUGINPATH} ]; then
        PLUGINPATH="$HOME/approot/CodistoConnect"
fi

if [ -z ${PHPVERSION} ]; then
        PHPVERSION="5.2"
fi

cd "$PLUGINPATH"

#If caller wants to save current state, stash then pop do so
if [ -n "$STASHPOP" ]; then
        git stash >/dev/null 2>&1
fi

#Make sure all remotes are up to date before we pull or checkout SHA's which might not exist
git fetch --all --prune >/dev/null 2>&1

#Pull specific SHA1 - This is ideal for web hook receive - you can redeliver a packet and it will checkout correct SHA and create correct tag etc
logger -s "Checking out commit $SHA1"
git checkout "$SHA1" --force >/dev/null 2>&1

if [ -n "$STASHPOP" ]; then
        git stash pop >/dev/null 2>&1
fi

logger -s "Linting .."
logger -s "phpcs --standard=$HOME/approot/CodistoConnectQA/tasks/linting/codistostandard.xml --runtime-set testVersion $PHPVERSION -d date.timezone=Australia/Sydney $PLUGINPATH --report-width=200"

phpcs --standard="$HOME/approot/CodistoConnectQA/tasks/linting/codistostandard.xml" --runtime-set testVersion "$PHPVERSION" -d date.timezone=Australia/Sydney "$PLUGINPATH" --report-width=200
logger -s "Linting complete"

#make sure the last thing that is sent to STDOUT is the $PLUGINPATH so we can strip that off filenames when applying comments on github as they need to be relative to the repo
logger -s "Plugin path is $PLUGINPATH"
echo $PLUGINPATH


