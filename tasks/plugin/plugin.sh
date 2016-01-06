#!/bin/bash

#NOTES - the php script requires components of magento to work and as such magento needs to be downloaded into the PLUGINPATH/src

#The branch to use to package up (Default development)
BRANCH=$1

#Determines if stashing current state before pull or checking out a specific SHA occurs followed by popping after the action is completed
STASHPOP=$2

#The specific SHA1 hash of the commit to checkout
SHA1=$3

#Resellerkey
RESELLER=$4

GITHUBTOKEN=$5

#Flag to indicate if creating a package with Magneto Connect XML node
MAGENTOCONNECT=$6

TEST=$7

#Variables that might be set but have empty values should be unset to simplify logic below
if [[ ${SHA1} ]]; then
	if [[ $SHA1 = "n/a" ]]; then
		logger -s "SHA1 variable exists but is set to n/a so unset"
		unset SHA1
	else
		logger -s "SHA1 variable exists and is set and all good"
	fi
else
	logger -s "SHA1 variable exists but is empty so unsetting"
	unset SHA1
fi


if [[ ${RESELLER} ]]; then
	if [[ ${RESELLER} = "n/a" ]]; then
		logger -s "RESELLER variable exists but is set to n/a so unset"
		unset RESELLER
	else
		logger -s "RESELLER variable exists and is set and all good"
	fi
else
	logger -s "RESELLER variable exists but is empty so unsetting"
	unset RESELLER
fi

#We either want to do a Reseller build if this variable is explicitely set or if there was a push to master
if [[ ${MAGENTOCONNECT} ]]; then
	if [[ ${MAGENTOCONNECT} = "n/a" ]]; then
		logger -s "Magento variable exists but is set to n/a so unset"
		unset MAGENTOCONNECT
	else
		logger -s "MAGENTOCONNECTvariable exists and is set and all good"
	fi
else
	logger -s "MAGENTOCONNECT variable exists but is empty so unsetting"
	unset MAGENTOCONNECT
fi

logger -s "Arguments are $@"

if [ -z ${SCRIPTPATH+x} ]; then
	SCRIPTPATH="$HOME/approot/CodistoConnectQA/tasks/plugin"
fi

if [ -z ${PLUGINPATH+x} ]; then
	PLUGINPATH="$HOME/approot/CodistoConnect"
fi

if [ -z ${BRANCH+y} ]; then
	BRANCH="development"
fi

if [ -z ${BUILDPATH+y} ]; then
	BUILDPATH="/tmp/build/"
	mkdir -p $BUILDPATH
fi

logger -s "Using the following paths "
logger -s "SCRIPTPATH=$SCRIPTPATH"
logger -s "PLUGINPATH=$PLUGINPATH"
logger -s "BRANCH=$BRANCH"
logger -s "BUILDPATH=$BUILDPATH"

logger -s "Using the followoing options"
logger -s "STASHPOP=$STASHPOP"
logger -s "SHA1=$SHA1"
logger -s "RESELLER=$RESELLER"
logger -s "GITHUBTOKEN=$GITHUBTOKEN"
logger -s "MAGENTOCONNECT=$MAGENTOCONNECT"
logger -s "TEST=$TEST"

cd $PLUGINPATH

logger -s "CURRENT SHA1=$(git rev-parse HEAD)"

if [ -n $STASHPOP ]; then
	if [ -z ${TEST} ]; then
		logger -s "STASHING"
		git stash
	fi
fi

#Make sure all remotes are up to date before we pull or checkout SHA's which might not exist
git fetch --all --prune


if [[ $SHA1 ]]; then

	#Pull specific SHA1 - This is ideal for web hook receive - you can redeliver a packet and it will checkout correct SHA and create correct tag etc
	logger -s "SHA1 was specified so checking out commit $SHA1"
	git checkout $SHA1 --force

else

	#If no specific SHA was specified then pull latest code
	logger -s "No SHA1 was specified so checking out $BRANCH and pulling"
	git checkout $BRANCH
	git pull

fi

if [[ $STASHPOP ]]; then

	if [ -z ${TEST} ]; then
		git stash pop
	fi

fi

#Save current SHA1 for CodistoConnect repo
cd $PLUGINPATH
SHA1=`git rev-parse HEAD`
SDATE=`date +%Y-%m-%d:%H:%M:%S`

logger -s "Current plugin will be built from SHA1 $SHA1"

PLUGINVERSION=`awk '/<version>/ {print $1}' $PLUGINPATH/code/community/Codisto/Sync/etc/config.xml | tr -d '<version>/'`

logger -s "PLUGINVERSION is $PLUGINVERSION"

#If its a normal master push without reseller or magentoconnect nodes then do the full workflow
if [ $BRANCH = "master" ] && [ -z $RESELLER ]  && [-z $MAGENTOCONNECT];	then

 	logger -s "Master was pushed and reseller was not specified so I'm doing full build"
	logger -s "Master branch has been pushed - Updating everything"

	#Let's update the plugin version
	PLUGINTUPLE=(${PLUGINVERSION//./ })
	MINOR=$((${PLUGINTUPLE[2]} +1))
	PLUGINVERSION="${PLUGINTUPLE[0]}.${PLUGINTUPLE[1]}.$MINOR"

	#Find the SHA1 hash of the development commit that was just merged
	DEVSHAGREP=$(git log -n1 | grep Merge:)
	DEVSHATUPLE=(${DEVSHAGREP// / })
	DEVSHA=${DEVSHATUPLE[2]}

	logger -s "Bumping version to $PLUGINVERSION"

	#Let's update data-install in code/community/Codisto/Sync/data/codisto_setup must have a matching file suffix to the plugin version. Let's rename it to match, commit the change and push with a particular commit message
	DATAINSTALLFNAME=`find -name "data-install-*" -type f -printf "%f"`

	logger -s "Updating version of $DATAINSTALLFNAME to data-install-$PLUGINVERSION.php"
	logger -s "Renaming $PLUGINPATH/code/community/Codisto/Sync/data/codisto_setup/$DATAINSTALLFNAME to $PLUGINPATH/code/community/Codisto/Sync/data/codisto_setup/data-install-$PLUGINVERSION.php"

	mv "$PLUGINPATH/code/community/Codisto/Sync/data/codisto_setup/$DATAINSTALLFNAME" "$PLUGINPATH/code/community/Codisto/Sync/data/codisto_setup/data-install-$PLUGINVERSION.php"

	logger -s "Commiting change to data-install"

	if [ -z ${TEST} ]; then
		git add "$PLUGINPATH/code/community/Codisto/Sync/data/codisto_setup/data-install-$PLUGINVERSION.php" -f
	fi

	#Lets update mysql4-install in code/community/Codisto/Sync/sql/codisto_setup must have matching file suffix to the plugin version so let's rename it to match

	MYSQLINSTALLFNAME=`find -name "mysql4-install-*" -type f -printf "%f"`

	logger -s "Updating version of $MYSQLINSTALLFNAME to mysql4-install-$PLUGINVERSION"
	logger -s "(FROM) $PLUGINPATH/code/community/Codisto/Sync/sql/codisto_setup/$MYSQLINSTALLFNAME"
	logger -s "  (TO)$PLUGINPATH/code/community/Codisto/Sync/sql/codisto_setup/mysql4-install-$PLUGINVERSION.php"

	mv "$PLUGINPATH/code/community/Codisto/Sync/sql/codisto_setup/$MYSQLINSTALLFNAME" "$PLUGINPATH/code/community/Codisto/Sync/sql/codisto_setup/mysql4-install-$PLUGINVERSION.php"
	logger -s "Commiting change to mysql4-install"

	if [ -z ${TEST} ]; then
		git add "$PLUGINPATH/code/community/Codisto/Sync/sql/codisto_setup/mysql4-install-$PLUGINVERSION.php" --force
	fi


	#Update config.xml with new plugin version
	sed -ri "/1/s/([0-9]+.[0-9]+.[0-9]+)/$PLUGINVERSION/" "$PLUGINPATH/code/community/Codisto/Sync/etc/config.xml"

	if [ -z ${TEST} ]; then

		#Generate a new CHANGELOG.md and add it
		rm CHANGELOG.md --force
		logger -s "Generating new changelog"
		github_changelog_generator --token $GITHUBTOKEN
		git add CHANGELOG.md

		logger -s "git add $PLUGINPATH/code/community/Codisto/Sync/etc/config.xml"
		git add "$PLUGINPATH/code/community/Codisto/Sync/etc/config.xml"

		logger -s "Committing version bumped files"
		git commit -am "BOT - Update data-install.php , bump plugin version and generate new changelog"

		#Update master
		git branch -D master
		git checkout -b master

		logger -s "Pusing master"
		git push origin master --force

	else
		logger -s "Not pushing master - integration tests running"

	fi

	if [ -z ${TEST} ]; then

			#Create a new tag with the plugin version
			git tag -d "$PLUGINVERSION"
			git tag -a "$PLUGINVERSION" -m "Version $PLUGINVERSION"
			logger -s "Pusing tag"
			git push origin "$PLUGINVERSION" --force

	else

			logger -s "Not pushing tag - integration tests running"

	fi

  if [ -z ${TEST} ]; then

			#checkout development branch of the specific SHA
			logger -s "Checking out development branch with sha of $DEVSHA"
			git checkout $DEVSHA --force
			git merge "$PLUGINVERSION" --no-edit

			#we are in a detached state, kill development and recreate
			git branch -D development
			git checkout -b development

			logger -s "Pusing development"
			git push origin development --force

			#We are finished with development so back to the SHA1 that was checked out for master
		  git checkout master
	else

		logger -s "Not pushing development - integration tests running"

	fi

	cd $PLUGINPATH

fi

if [[ $RESELLER ]]; then
	echo "Reseller specified so doing SED magic"
	sed -i "s/<\/config>/\\t<codisto>\n\t\t<resellerkey>$RESELLER<\/resellerkey>\n\t<\/codisto>\n\n\n<\/config>/" "$PLUGINPATH/code/community/Codisto/Sync/etc/config.xml"
fi


if [[ $MAGENTOCONNECT ]]; then
	echo "Magento Connect  specified so doing SED magic"
	sed -i "s/<\/config>/\\t<codisto>\n\t\t<magentoconnect>1<\/magentoconnect>\n\t<\/codisto>\n\n\n<\/config>/" "$PLUGINPATH/code/community/Codisto/Sync/etc/config.xml"
fi

#Let's make an app directory in $BUILDPATH and copy + tar it there
mkdir -p "$BUILDPATH/app"
cp -R code design etc "$BUILDPATH/app"

cd "$BUILDPATH"

#Tar up plugin
tar cvf plugin.tar app/code/community/Codisto/* app/design/ebay/*
tar rvf plugin.tar app/etc/modules/*
cp plugin.tar codisto-tar-input.tar

cd "$PLUGINPATH"


#Update the php sample config with PLUGINVERSION
logger -s "Updating $SCRIPTPATH/example-config.php version to $PLUGINVERSION"
sed -ri "/1/s/([0-9]+.[0-9]+.[0-9]+)/$PLUGINVERSION/" "$SCRIPTPATH/example-config.php"

logger -s "Building extension in $SCRIPTPATH"

# Php build extension
cd "$SCRIPTPATH"

# Package up extension
env SCRIPTPATH="$SCRIPTPATH" BONDI_APPROOT="$HOME/approot" PLUGIN="plugin.tar" BUILDPATH="$BUILDPATH" php magento-tar-to-connect.php example-config.php


SUFFIX=""
logger -s "Building branch $BRANCH"

if [ "$BRANCH" == "development" ]; then
	SUFFIX="-beta"
elif [ "$BRANCH" != "master" ]; then
	#some custom/feature
	SUFFIX="($BRANCH)"
fi

logger -s "Plugin suffix is $SUFFIX"

#rename CodistoConnect-1.2.34.tgz  to CodistoConnect$SUFFIXversion.tgz

ORIGINALNAME=''$BUILDPATH'/codistoconnect-'$PLUGINVERSION'.tgz'
PLUGINFNAME=CodistoConnect$SUFFIX-$PLUGINVERSION-$RESELLER.tgz

logger -s "OriginalName is $ORIGINALNAME"
logger -s "PLUGINNAME is $PLUGINFNAME"
logger -s "RENAMING $ORIGINALNAME TO $BUILDPATH/$PLUGINFNAME"


mv "$ORIGINALNAME" "$BUILDPATH/$PLUGINFNAME"

#Copy extension into a place where magento clients can get it
logger -s "Copying $BUILDPATH/$PLUGINFNAME to $SCRIPTPATH/"
cp "$BUILDPATH/$PLUGINFNAME" "$SCRIPTPATH/"

#Clean up packager temporary files
rm -rf $BUILDPATH/*

#Plugin has been built for reseller  or Magento Connect so we need to restore the config file to previous state
if  [ ${RESELLER} ] || [${MAGENTOCONNECT}]; then
	cd ${PLUGINPATH}
	logger -s "About to restore config.xml after I have finished adding the reseller key back to version in ${SHA1}"
	git checkout ${SHA1} "code/community/Codisto/Sync/etc/config.xml"
	logger -s "Master I have restored the config.xml file and no reseller specific node exists anymore"
fi

#Don't do this for resellers

if [ -z $RESELLER ]; then
	if  [ "$BRANCH" == "development" ]  || [ "$BRANCH" == "master" ]; then

		if [ -z $TEST ]; then
			#Make a symlink so location is always the same when browser GET's the plugin (only if dev or master)
			logger -s "Making a symlink from $SCRIPTPATH/$PLUGINFNAME  to $SCRIPTPATH/CodistoConnect$SUFFIX.tgz"
			rm "$SCRIPTPATH/CodistoConnect$SUFFIX.tgz" >/dev/null 2>&1; ln -s "$SCRIPTPATH/$PLUGINFNAME" "$SCRIPTPATH/CodistoConnect$SUFFIX.tgz"

			logger -s "Copying to codisto.com"
			scp "$SCRIPTPATH/$PLUGINFNAME" "nwo@aws-chaos-us-w-1:/home/nwo/codisto/plugin/"

			#Create symlink to this new version on codisto.com
			if [ "$BRANCH" == "master" ]; then
				ssh nwo@aws-chaos-us-w-1 "rm /home/nwo/codisto/plugin/CodistoConnect.tgz >/dev/null 2>&1; ln -s /home/nwo/codisto/plugin/$PLUGINFNAME /home/nwo/codisto/plugin/CodistoConnect.tgz"
			fi

			if [ "$BRANCH" == "development" ]; then
				ssh nwo@aws-chaos-us-w-1 "rm /home/nwo/codisto/plugin/CodistoConnect-beta.tgz >/dev/null 2>&1; ln -s /home/nwo/codisto/plugin/$PLUGINFNAME /home/nwo/codisto/plugin/CodistoConnect-beta.tgz"
			fi
		fi
	fi
fi

logger -s "Plugin build completed"

if [ -z ${TEST} ]; then
	#Leave a note about build
	echo "extension built on $SDATE (branch [$BRANCH] - sha1[$SHA1]) - Extension package is -> $PLUGINFNAME">> $SCRIPTPATH/extensionbuildlog.txt
else

	logger -s "Restoring system state after test run"
	#restore filesystem state as we were only testing (its OK as the plugin builder only has one child so only testing or legitimate building can happen at once)

  logger -s "PLUGIN PATH IS $PLUGINPATH"
	cd $PLUGINPATH && git reset --hard && git clean -dfx --force
fi

#Leave plugin version and path to plugin as last line in STDOUT to be captured
echo "$PLUGINVERSION~~$PLUGINFNAME"
