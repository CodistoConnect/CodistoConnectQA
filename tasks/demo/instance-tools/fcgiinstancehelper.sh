#!/bin/bash
# Started via /opt/bitnami/scripts/init on demo instance

# Receives input from sandringham and in turn updates bitnami_magento database with updated merchant state
MERCHANTID=$1
HOSTKEY=$2
MAGENTOADMINPASS=$3

logger -s "Updating Merchant state - inside FasgtCGI Helper bash script"

#Update MerchantID and HostKey values for CodistoConnect

if [ -n "$MERCHANTID" ]; then
	mysql -u root -p${MYSQL_ROOT_PASS} --execute="UPDATE bitnami_magento.core_config_data SET value='$MERCHANTID' WHERE path = 'codisto/merchantid'"
fi

if [ -n "$HOSTKEY" ]; then
	mysql -u root -p${MYSQL_ROOT_PASS} --execute="UPDATE bitnami_magento.core_config_data SET value='$HOSTKEY' WHERE path = 'codisto/hostkey'"
fi

if [ -n "$MAGENTOADMINPASS" ]; then

	#Update Magento admin login
	mysql -u root -p${MYSQL_ROOT_PASS} --execute="UPDATE bitnami_magento.admin_user SET password=CONCAT(MD5('qX$MAGENTOADMINPASS'), ':qX') WHERE username = 'codistouser';"
fi

echo 'codistouser:$MAGENTOADMINPASS' | sudo chpasswd
echo "OK"