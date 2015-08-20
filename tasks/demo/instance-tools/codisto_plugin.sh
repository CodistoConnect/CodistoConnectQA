#!/bin/sh
# Started via /opt/bitnami/scripts/init on demo instance

echo ""
echo "#########################################################################"
echo "#                                                                       #"
echo "#        Installing latest CodistoConnect Magento Plugin                #"
echo "#                                                                       #"
echo "#########################################################################"
echo ""

cd /home/bitnami/apps/magento/htdocs/
./mage uninstall community CodistoConnect
wget -O plugin.tgz https://codisto.com/plugin/getstable
./mage install-file plugin.tgz
rm plugin.tgz

sudo chown -R bitnami:daemon /home/bitnami/apps/magento/htdocs/app/code/community/Codisto
sudo chown -R bitnami:daemon /home/bitnami/apps/magento/htdocs/app/etc/modules/Codisto*

echo "[`date`] Finished installing Codisto Magento Plugin" >> /home/bitnami/pluginlog.txt

