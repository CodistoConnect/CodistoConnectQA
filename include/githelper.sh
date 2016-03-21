#!/bin/bash

#The CWD for git operations
PLUGINPATH=${1}

#The specific SHA1 hash of the commit to checkout
SHA1=${2}

#Determines if stashing current state before pull or checking out a specific SHA occurs followed by popping after the action is completed
STASHPOP=${3}

TEST=${4}

logger -s "Githelper requested - Using Args"
logger -s "PLUGINPATH=${PLUGINPATH}"
logger -s "SHA1=${SHA1}"
logger -s "STASHPOP=${STASHPOP}"
logger -s "TEST=${TEST}"

if [ -d ${PLUGINPATH} ]; then

	cd ${PLUGINPATH}
	logger -s "CWD is ${PLUGINPATH}"

	CURRENTSHA1=$( git rev-parse HEAD )
	logger -s "Current SHA1 state is ${CURRENTSHA1}"

	CURRENTBRANCH=$(git rev-parse --abbrev-ref HEAD )
	logger -s "Current Branch is ${CURRENTBRANCH}"

	#If caller wants to save current state, stash then pop do so
	if [ -n ${STASHPOP} ]; then
		logger -s "Stashing Git stack"
		STASHSTDOUT=$( git stash )
		logger -s ${STASHSTDOUT}
	fi

	RESETSTDOUT=$( git reset --hard HEAD )
	logger -s ${RESETSTDOUT}

	#Make sure all remotes are up to date before we pull or checkout SHA's which might not exist
	logger -s "Updating remotes ..."
	FETCHSTDOUT=$( git fetch --all --prune )
	logger -s ${FETCHSTDOUT}

	#Variables that might be set but have empty values should be unset to simplify logic below
	if [[ ${SHA1} ]]; then
		if [[ ${SHA1} = "n/a" ]]; then
			logger -s "SHA1 variable exists but is set to n/a so unset."
			unset SHA1
		else
			logger -s "SHA1 variable exists and is set."
		fi
	else
		logger -s "SHA1 variable exists but is empty so unsetting."
		unset SHA1
	fi

	if [[ ${STASHPOP} ]]; then
		logger -s "Stashpop was specified"
		#Stashpop functionality was requested but wasn't 1 so unset it as the input is meanlingless
		if [[ "${STASHPOP}" != "1" ]]; then
			logger -s "Unsetting Stashpop - Value other than 1 was encounted [${STASHPOP}]"
			unset STASHPOP
		fi
	fi


	if [[ ${SHA1} ]]; then

		ISHEAD=$( git for-each-ref --format="%(refname:short) %(objectname)" 'refs/heads/' | grep ${SHA1} | cut -d " " -f 1 )
		if [[ -z ${ISHEAD} ]]; then
			logger -s "WARNING - ${SHA1} build requested but is not HEAD commit for the current branch [${CURRENTBRANCH}]"
		fi

		ISBRANCH=$( git branch | grep ${SHA1} )
		if [[ ${ISBRANCH} ]]; then
			BRANCH=${SHA1}
			unset SHA1
			logger -s "SHA1 pushed was a branch name [${BRANCH}]. Will checkout that branch and pull the latest commit."
			CHECKOUTSTDOUT=$( git checkout ${BRANCH} --force && git pull )
		else
			CHECKOUTSTDOUT=$( git checkout ${SHA1} --force )
		fi
		logger -s "Checkout complete"
		logger -s ${CHECKOUTSTDOUT}
	fi

	if [ -n "${STASHPOP}" ]; then
		logger -s "Popping Git stack"
		POPSTDOUT=$( git stash pop )
		logger -s ${POPSTDOUT}
	fi
else
	logger -s "${PLUGINPATH} was specified but doesn't exist !"
	echo "ERROR - ${PLUGINPATH} was specified but doesn't exist !" # ReponseBody text
	exit -1
fi

echo "OK|${SHA1}|${BRANCH}"
