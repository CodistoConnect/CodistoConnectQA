#!/bin/bash
logger -s "Marketplace Connect plugin build commencing ..."

#TODO
#after changelog.md is generated then we want to parse that for all the changes and prepend that to https://github.com/CodistoConnect/CodistoConnect-WooCommerce/blob/development/codisto/readme.txt#L90 ==
#svn commit the current state of the checked out SHA1 hash to the remote subversion box on wordpress
#Make sure that all inputs are handled cleanly //{GITHUBTOKEN} {PLUGINPATH} {BUILDPATH} {TEST} {RESELLERKEY}

#Global Vars
PLUGINNAME="Marketplace Connect"
DEBUGSTDOUT=0
DEBUGSYSLOG=1
DEBUGVERBOSE=1

GITHUBTOKEN=${1}
PLUGINPATH=${2}
BUILDPATH=${3}
TEST=${4}
RESELLERKEY=${5}
CONFIGFILE="${PLUGINPATH}/readme.txt"
GITHUBARTIFACT="CodistoConnect-WooCommerce"
GITHUBEXTENSION=".zip"


if [ ${DEBUGVERBOSE} = 1 ]; then
	PS4='$LINENO: '
	set -x
fi

log ()
{
	#if [ ${DEBUGSTDOUT} = 1 ]; then
		echo ${1}
	#fi

	#if [ ${DEBUGSYSLOG} = 1 ]; then
		#Syslog / JournalCtl etc
	#	logger -s ${1}
	#fi
}

setup ()
{
	log "Performing Setup"
	log "****************"

	if [ -n ${RESELLERKEY} ]; then
		log "Reseller Key specified for ${PLUGINNAME} but not used. Ignoring"
	fi

	if [ -z ${PLUGINPATH} ]; then
		PLUGINPATH="${HOME}/approot/CodistoConnect-WooCommerce/codisto"
		log "Plugin Path was not specified. It has been set to ${PLUGINPATH}"

		if [ ! -d ${PLUGINPATH} ]; then
			log "FATAL ERROR - ${PLUGINPATH} doesn't exist"
			exit -1
		fi
	fi

	if [ -z ${BUILDPATH} ]; then
		BUILDPATH="/tmp/CodistoConnect-WooCommerce/"
		log "Build Path was not specified. It has been set to ${BUILDPATH}"

		if [ ! -d ${BUILDPATH} ]; then
			log "FATAL ERROR - ${BUILDPATH} doesn't exist"
			exit -1
		fi
	fi

	log "Using the following paths "
	log "*************************"
	log "PLUGINPATH=${PLUGINPATH}"
	log "BUILDPATH=${BUILDPATH}"
	log "Using the following options"
	log "***************************"
	log "GITHUBTOKEN=${GITHUBTOKEN}"
	log "TEST=${TEST}"
	log "RESELLER=${RESELLER}"
	log "Using Configuration file ${CONFIGFILE}"

}

getpluginversion ()
{
	local PLUGINVERSION=$( cat ${CONFIGFILE} | egrep "Stable tag" | cut -d':' -f 2 | cut -d' ' -f 2 )
	log "Marketplace Connect existing plugin version is ${PLUGINVERSION}"
	echo ${PLUGINVERSION}
}

setpluginversionbump ()
{
	local PLUGINVERSIONTUPLE=(${1//./ })
	local MINOR=$((${PLUGINVERSIONTUPLE[2]} +1))
	local PLUGINVERSION="${PLUGINVERSIONTUPLE[0]}.${PLUGINVERSIONTUPLE[1]}.${MINOR}"
	log "Marketplace Connect new plugin version is ${PLUGINVERSION}"
	echo ${PLUGINVERSION}
}

#Updates Version Number, Release notes etc
setconfig ()
{
	#Update Version Number
	local PLUGINVERSION=${1}
	sed -ri "/1/s/(Stable tag: [0-9]+.[0-9]+.[0-9]+)/Stable tag: ${PLUGINVERSION}/" "${CONFIGFILE}"

	#TODO Do I need to copy all pull request commits to the readme.txt too ? I'm tempted to point to the CHANGELOG.md for this version
}

getgitmetadata ()
{
	#Get some information about origin remote
	local ORIGINPUSH=$(git remote -v | egrep -e "origin" | egrep -e "push" | cut -d$'\t' -f2 | cut -d' ' -f1)
	local ORIGINFETCH=$(git remote -v | egrep -e "origin" | egrep -e "fetch" | cut -d$'\t' -f2 | cut -d' ' -f1)

	#Get Current SHA1 hash
	local SHA1=$(git rev-parse HEAD)
	local SDATE=$(date +%Y-%m-%d:%H:%M:%S)

	#If the SHA is a on the head of a branch it will return values like master otherwise HEAD
	local BRANCH=$(git rev-parse --abbrev-ref HEAD)

	#Find the SHA1 hash of the development commit that was just merged
	local DEVSHAGREP=$(git log -n1 | grep Merge:)
	local DEVSHATUPLE=(${DEVSHAGREP// / })
	local DEVSHA=${DEVSHATUPLE[2]}

	echo "${SHA1}|${BRANCH}|${SDATE}|${DEVSHA}|${ORIGINFETCH}|${ORIGINPUSH}"
}

#This is only used to package up as a zip archive and add as a release artifact
packageplugin ()
{
	if [ "${BRANCH}" = "development" ]; then
		SUFFIX="-beta"
	elif [ "${BRANCH}" != "master" ]; then
		SUFFIX="($BRANCH)"
	fi

	ARTIFACTPATH=${BUILDPATH}${GITHUBARTIFACT}${SUFFIX}${GITHUBEXTENSION}
	log "Packaging ${PLUGINPATH} into build artifact ${ARTIFACTPATH}"
	#Compress files ready to go
	ZIPSTDOUT=$(zip -r ${ARTIFACTPATH} ${PLUGINPATH})
	log ${ZIPSTDOUT}
	echo "${ARTIFACTPATH}"
}

#This will upload via SVN here. On Codisto Connect version it will upload to QA box and scp to chaos etc
uploadplugin()
{
	#svn commit -m "log messages"
	exit -1
}

#Brad playing around
testversionbump()
{
	EXISTINGPLUGINVERSION=$(getpluginversion)
	echo "PLUGIN VERSION IS ${EXISTINGPLUGINVERSION}"
	PLUGINVERSION=$(setpluginversionbump "${EXISTINGPLUGINVERSION}")
	echo "NEW VERSION IS ${PLUGINVERSION}"
	setconfig ${PLUGINVERSION}
	UPDATEDVERSION=$(getpluginversion)
	echo "UPDATED VERSION ON DISK IS ${UPDATEDVERSION}"
}

buildplugin ()
{
	cd ${PLUGINPATH}

	GITMETADATA=$(getgitmetadata)
	log "->->-> ${GITMETADATA}"
	GITMETADATA=(${GITMETADATA//|/ })
	local SHA1=${GITMETADATA[0]}
	local BRANCH=${GITMETADATA[1]}
	local SYSDATE=${GITMETADATA[2]}
	local DEVSHA=${GITMETADATA[3]}
	local	ORIGINFETCH=${GITMETADATA[4]}
	local ORIGINPUSH=${GITMETADATA[5]}

	log "Building plugin"
	log "***************"
	log "SHA1=${SHA1}"
	log "DEVSHA=${DEVSHA}"
	log "BRANCH=${BRANCH}"
	log "SYSDATE=${SYSDATE}"
	log "Remote [origin] fetch = ${ORIGINFETCH}"
	log "Remote [origin] push = ${ORIGINPUSH}"
	exit 0

	PLUGINVERSION=$(getpluginversion)

	#Pseudocode
	#If the push was to master and no reseller was set
	#	Bump plugin version in config and any other associated files
	#	If not test mode
	#		Delete tag matching the new bumped version and re-create it if it exists (useful for replaying webhooks)
	#		Force push this tag to remote as Changelog generator uses remote tags not local
	#		Delete existing CHANGELOG.md and generate a new one
	#		Commit the new CHANGELOG.md and changed config and any other associated files to git
	#		Delete tag matching the new bumped version and re-create it (We are moving the tag forward with the new changelog)
	#		Force push the tag so remote is up to date and tag is moved along
	#		Delete the current master and checkout current sha as master
	#		Force push master
	#		Checkout the DEVSHA that made its way into master
	#		Backport the tag created for this plugin version (Merge the tag)
	#		Delete current development and checkout current sha as development
	#		For push development
	#	End if
	#	If reseller
	#		Update configuration file with Reseller data if applicable
	#	End If
	#	Create archive in builddir with contents of pluginpath (Package it)
	#	If the build is development or branch not dev
	#		add -BETA suffix.. if it is a custom branch then add the branch name as the suffix
	#	End If
	#	If Reseller
	#		Restore the configuration
	#	End If
	#	If NOT Reseller
	#		If Branch is master or development and NOT test mode
	#			Deploy the plugin (copy to chaos via scp) for woo this also means updating readme.txt with changelog text and making a new subversion commit.
	#		End If
	#	End if
	#	Reset all state
	#	Write the pluginname and version to STDOUT so that Server side JS can grab them and do github further work

	#If the push was to master and no reseller was set
	if [ ${BRANCH} = "master" ] && [ -z ${RESELLER} ];	then
		log "master branch was pushed and RESELLER flag was not specified. Full build commencing"
		#	Bump plugin version in config and any other associated files
		PLUGINVERSION=$(setpluginversionbump "${EXISTINGPLUGINVERSION}")
		setconfig ${PLUGINVERSION}

		#	If not test mode
		if [ -z ${TEST} ]; then
			#		Delete tag matching the new bumped version and re-create it if it exists (useful for replaying webhooks)
			git tag -d ${PLUGINVERSION}
			git tag -a ${PLUGINVERSION} -m "Version ${PLUGINVERSION}"
			#		Force push this tag to remote as Changelog generator uses remote tags not local
			TAGPUSHSTDOUT=$(git push origin ${PLUGINVERSION} --force)
			log ${TAGPUSHSTDOUT}
			#		Delete existing CHANGELOG.md and generate a new one
			rm CHANGELOG.md --force >/dev/null 2>&1
			log "Generating new changelog"
			CHANGESTDOUT=$(github_changelog_generator --token ${GITHUBTOKEN})
			log ${CHANGESTDOUT}
			#		Commit the new CHANGELOG.md and changed config and any other associated files to git
			log "Committing version bumped files and new changelog"
			COMMITSTDOUT=$(git commit -am "BOT - Update data-install.php , bump plugin version and generate new changelog")
			log ${COMMITSTDOUT}
			#		Delete tag matching the new bumped version and re-create it (We are moving the tag forward with the new changelog)
			git tag -d ${PLUGINVERSION}
			git tag -a ${PLUGINVERSION} -m "Version ${PLUGINVERSION}"
			#		Force push the tag so remote is up to date and tag is moved along
			git push origin ${PLUGINVERSION} --force
			#		Delete the current master and checkout current sha as master
			git branch -D master ;	git checkout -b master
			#		Force push master
			log "Pushing master to remote"
			git push origin master --force
			#		Checkout the DEVSHA that made its way into master
			log "Checking out development branch with sha of ${DEVSHA}"
			git checkout ${DEVSHA} --force
			#		Backport the tag created for this plugin version (Merge the tag)
			git merge ${PLUGINVERSION} --no-ff --no-edit
			#		Delete current development and checkout current sha as development
			git branch -D development
			git checkout -b development
			#		For push development
			log "Pushing development"
			git push origin development --force
		fi
		#End If
		#	If reseller
		if [ -n ${RESELLER} ]; then
		#		Update configuration file with Reseller data if applicable
			log "RESELLER flag specified but not used. Ignoring"
		#	End If
		fi
		#	Create archive in builddir with contents of pluginpath (Package it)
		PLUGINFNAME=$(packageplugin ${BRANCH})

		#	If NOT Reseller
		if [ -z ${RESELLER} ]; then
			# If Branch is master or development and NOT test mode
			if  [ "${BRANCH}" == "development" ]  || [ "${BRANCH}" == "master" ] && [ -z ${TEST} ]; then
				# Deploy the plugin (copy to chaos via scp) for Woo this also means updating readme.txt with changelog text and making a new subversion commit.
				uploadplugin
				# End If
			fi
		#	End if
		fi
		#	Reset all state
		cd ${PLUGINPATH} && git reset --hard && git clean -dfx --force

	fi

	log "Marketplace Connect plugin build completed ..."

	#Used by serverside JS to create releases and upload artifacts etc as the last thing written to STDOUT becomes ResponseBody
	echo "$PLUGINVERSION~~$PLUGINFNAME"
}

setup
buildplugin
