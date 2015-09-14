
#Start mysql temporarily to import magento structures, sample data and so on use script from /init.d as it makes sure mysql has started correctly
service mysql start

#Populate the initial testing database
cd ${BUILDENV}/htdocs

${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group EcomDev_PHPUnitTest


if [ -z $TESTS ] ; then
	echo "Tests were not enabled. Deploying container with Magento + Codisto Connect for manual testing / dev"
else

	echo "Running CodistoConnect tests .."

	${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group Codisto_Sync
fi

