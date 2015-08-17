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

# check if this is a travis environment
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

#TODO - enable run unit + integration tests on container start if environment variable set
if [ -z $TESTS ] ; then
	echo "Tests were not enabled. Deploying container with Magento + Codisto Connect for manual testing / dev"
else
	echo "Running tests .."
	cd ${BUILDENV}/htdocs
	${BUILDENV}/bin/phpunit --colors -d display_errors=1
fi


