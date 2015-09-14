
#Populate the initial testing database
cd ${BUILDENV}/htdocs

#${BUILDENV}/bin/phpunit --colors -d display_errors=1
${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group EcomDev_PHPUnitTest


if [ -z $TESTS ] ; then
	echo "Tests were not enabled. Deploying container with Magento + Codisto Connect for manual testing / dev"
else

	echo "Running CodistoConnect tests .."

	${BUILDENV}/bin/phpunit --colors -d display_errors=1 --group Codisto_Sync
fi

