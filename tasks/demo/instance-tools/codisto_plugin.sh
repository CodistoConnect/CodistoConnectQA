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

#this is no longer correct as the complete path to the chroot location needs to be owned by root and only writable by root
#sudo chown -R bitnami:daemon /home/bitnami/apps/magento/htdocs/app/code/community/Codisto
#sudo chown -R bitnami:daemon /home/bitnami/apps/magento/htdocs/app/etc/modules/Codisto*

echo "[`date`] Finished installing Codisto Magento Plugin" >> /home/bitnami/pluginlog.txt

