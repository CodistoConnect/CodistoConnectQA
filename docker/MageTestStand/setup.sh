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


function codistoPlugin {
	cd $CODISTOCONNECT_WORKSPACE
	rm -rf CodistoConnect

	#TODO change this to master when ci stuff is merged
	git clone git://github.com/CodistoConnect/CodistoConnect.git -b bm_travis_ci
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

#start mysql temporarily to import magento structures, sample data and so on
/bin/bash -c "/usr/bin/mysqld_safe &"

#clone down Codisto plugin
codistoPlugin

BUILDENV=`mktemp -d /tmp/mageteststand.XXXXXXXX`

echo "Using build directory ${BUILDENV}"

git clone https://github.com/AOEpeople/MageTestStand.git "${BUILDENV}"
cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

#replace install.sh sample data line to indicate that sample data is required -- get stuff working before we bother with sample data
#sed -i -e s/--installSampleData=no/--installSampleData=yes/ "${BUILDENV}/install.sh"

${BUILDENV}/install.sh
if [ -d "${WORKSPACE}/vendor" ] ; then
	cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

cd ${BUILDENV}/htdocs
${BUILDENV}/bin/phpunit --colors -d display_errors=1
