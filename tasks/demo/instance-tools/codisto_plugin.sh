#!/bin/sh
# Started via /opt/bitnami/scripts/init on demo instance

echo ""
echo "#########################################################################"
echo "#                                                                       #"
echo "#        Installing latest CodistoConnect Magento Plugin                #"
echo "#                                                                       #"
echo "#########################################################################"
echo ""

/bin/bash -c "source /etc/profile"


cd /home/bitnami/apps/magento/htdocs/
./mage uninstall community CodistoConnect

rm -R /home/bitnami/apps/magento/htdocs/app/design/

mysql -u root -p${MYSQL_ROOT_PASS} --execute="DELETE FROM bitnami_magento.core_resource WHERE code = 'codisto_setup';"

wget -O plugin.tgz https://codisto.com/plugin/getstable
./mage install-file plugin.tgz
rm plugin.tgz

sudo chown -R root:daemon /home/bitnami/apps/magento/htdocs/app/code/community/Codisto
sudo chown -R root:daemon /home/bitnami/apps/magento/htdocs/app/etc/modules/Codisto*

sudo chmod -R 750 /home/bitnami/apps/magento/htdocs/app/code/community/Codisto
sudo chmod -R 750 /home/bitnami/apps/magento/htdocs/app/etc/modules/Codisto_Sync.xml










echo "[`date`] Finished installing Codisto Magento Plugin" >> /home/bitnami/pluginlog.txt

