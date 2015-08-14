#!/bin/bash

if [ -z $MAGENTO_DB_HOST ]; then MAGENTO_DB_HOST="localhost"; fi
if [ -z $MAGENTO_DB_PORT ]; then MAGENTO_DB_PORT="3306"; fi
if [ -z $MAGENTO_DB_USER ]; then MAGENTO_DB_USER="root"; fi
if [ -z $MAGENTO_DB_PASS ]; then MAGENTO_DB_PASS=""; fi
if [ -z $MAGENTO_DB_NAME ]; then MAGENTO_DB_NAME="mageteststand"; fi
if [ -z $MAGENTO_DB_ALLOWSAME ]; then MAGENTO_DB_ALLOWSAME="0"; fi
if [ -z $MAGENTO_BASEURL ]; then MAGENTO_BASEURL="http://magentodev.local/"; fi
if [ -z $MAGENTO_SAMPLE_DATA ]; then MAGENTO_SAMPLE_DATA="yes"; fi

echo
echo "---------------------"
echo "- AOE MageTestStand -"
echo "---------------------"
echo
echo "Installing ${MAGENTO_VERSION} in ${SOURCE_DIR}/htdocs"
echo "using Database Credentials:"
echo "    Host: ${MAGENTO_DB_HOST}"
echo "    Port: ${MAGENTO_DB_PORT}"
echo "    User: ${MAGENTO_DB_USER}"
echo "    Pass: [hidden]"
echo "    Main DB: ${MAGENTO_DB_NAME}"
echo "    Test DB: ${MAGENTO_DB_NAME}_test"
echo "    Allow same db: ${MAGENTO_DB_ALLOWSAME}"
echo

#cd ${SOURCE_DIR}

if [ ! -f htdocs/app/etc/local.xml ] ; then

	# Create main database
	MYSQLPASS=""
	if [ ! -z $MAGENTO_DB_PASS ]; then MYSQLPASS="-p${MAGENTO_DB_PASS}"; fi
	mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}\`; CREATE DATABASE \`${MAGENTO_DB_NAME}\`;"

	sed -i -e s/MAGENTO_DB_HOST/${MAGENTO_DB_HOST}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	sed -i -e s/MAGENTO_DB_PORT/${MAGENTO_DB_PORT}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	sed -i -e s/MAGENTO_DB_USER/${MAGENTO_DB_USER}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	sed -i -e s/MAGENTO_DB_PASS/${MAGENTO_DB_PASS}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	sed -i -e s/MAGENTO_DB_ALLOWSAME/${MAGENTO_DB_ALLOWSAME}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit

	if [ $MAGENTO_DB_ALLOWSAME == "0" ] ; then
		# Create test database
		mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}_test\`; CREATE DATABASE \`${MAGENTO_DB_NAME}_test\`;"
		sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}_test/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	else
		sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit
	fi

	tools/n98-magerun.phar install \
      --dbHost="${MAGENTO_DB_HOST}" --dbUser="${MAGENTO_DB_USER}" --dbPass="${MAGENTO_DB_PASS}" --dbName="${MAGENTO_DB_NAME}" --dbPort="${MAGENTO_DB_PORT}" \
      --installSampleData=no \
      --useDefaultConfigParams="${MAGENTO_SAMPLE_DATA}" \
      --magentoVersionByName="${MAGENTO_VERSION}" \
      --installationFolder="${BUILDENV}/htdocs" \
      --baseUrl="${MAGENTO_BASEURL}" || { echo "Installing Magento failed"; exit 1; }
fi

#Link codistoconnect and magento
tools/modman deploy-all --force

#Install https://github.com/EcomDev/EcomDev_PHPUnit.git
if [ ! -f $BUILDENV/composer.lock ] ; then cd $BUILDENV && $BUILDENV/tools/composer.phar install --no-interaction ; fi


#Set Magento development configuration
tools/n98-magerun.phar --root-dir=htdocs config:set dev/template/allow_symlink 1
tools/n98-magerun.phar dev:symlinks --on --global
tools/n98-magerun.phar dev:log --on --global
