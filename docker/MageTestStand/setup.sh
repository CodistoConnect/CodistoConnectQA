#!/bin/bash
set -e
set -x

#Adapted from https://raw.githubusercontent.com/AOEpeople/MageTestStand/master/install.sh

function cleanup {
	if [ -z $SKIP_CLEANUP ]; then
		echo "Removing build directory ${BUILDENV}"
		rm -rf "${BUILDENV}"
	fi
}


trap cleanup EXIT

# check if this is a Travis environment
if [ ! -z $TRAVIS_BUILD_DIR ] ; then
	WORKSPACE=$TRAVIS_BUILD_DIR
fi

if [ -z $WORKSPACE ] ; then
	echo "No workspace configured, please set your WORKSPACE environment"
	exit
fi

#Start mysql temporarily to import magento structures, sample data and so on use script from /init.d as it makes sure mysql has started correctly
service mysql start

echo "Using build directory ${BUILDENV}"

cd $BUILDENV
$SCRIPTS/install.sh

if [ -d "${WORKSPACE}/vendor" ] ; then
	cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

#Link CodistoConnect and any other modules such as ecom dev phpunit testing framework with Magento using Modman (sym link)
tools/modman deploy-all --force

#Populate the initial testing database
${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group EcomDev_PHPUnitTest


if [ -z $TESTS ] ; then
	echo "Tests were not enabled. Deploying container with Magento + Codisto Connect for manual testing / dev"
else

	echo "Running CodistoConnect tests .."

	${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group Codisto_Sync
fi


