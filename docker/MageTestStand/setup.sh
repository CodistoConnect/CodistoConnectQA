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

 
#Stop github rate limiting .. provide token for public repo only
$BUILDENV/tools/composer.phar config --global github-oauth.github.com 46fef9ded53e4c3910bfef21e509d00e40784468

$SCRIPTS/install.sh

if [ -d "${WORKSPACE}/vendor" ] ; then
	cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

$SCRIPTS/codisto_update
$SCRIPTS/tests.sh



