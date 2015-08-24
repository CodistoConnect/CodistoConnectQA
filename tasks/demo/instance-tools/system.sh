#!/bin/bash

#NOTES
# - sshd's strict ownership/permissions requirements dictate that every directory in the chroot path must be owned by root and only writable by the owner (root).
# - Mirrors for apt-fast are set to MIRRORS=( 'us-east-1.ec2.archive.ubuntu.com/ubuntu,us-east-2.ec2.archive.ubuntu.com/ubuntu,us-west-1.ec2.archive.ubuntu.com/ubuntu' )


MDATE=`date +%Y-%m-%d:%H:%M:%S`

/bin/bash -c "source /etc/profile"

sudo apt-fast update && sudo apt-fast upgrade -y -f

echo "Merchantstate updated on $MDATE MerchantID to $MERCHANTID , HostKey to $HOSTKEY, MagentoAdminPass to $MAGENTOADMINPASS" >> /home/bitnami/merchantstateupdate.log

#Lock down everything
sudo usermod -G daemon,adm,bitnami bitnami

#Change ownership of core directories and update symlinks too
sudo chown -h -R root:bitnami /opt/bitnami
sudo chown -h -R root:bitnami /home/bitnami

sudo chmod -R 770 /home/bitnami #(root and bitnami group member should be able to write in /home/bitnami (recurse and set all)
sudo chmod 750 /home/bitnami #(now lock down /home/bitnami again for chroot)

#Now loosen up access so php-fpm and apache2 can read and execute from /home/bitnami/apps and /home/bitnami/htdocs
sudo chmod -R 755 /home/bitnami/apps #(no write except for root into apps (chroot openssh related)
sudo chmod -R 755 /home/bitnami/htdocs #(no write execpt for root into htdocs)

#Now update ownership for specific web stack related stuff
sudo chown -h -R root:daemon /home/bitnami/apps #(apache and php-fpm access)
sudo chown -h -R root:daemon /home/bitnami/htdocs #(apache and php-fpm access)
sudo chown -h -R root:daemon /home/bitnami/stack #(apache and php-fpm access)

sudo chown -h -R root:daemon /opt/bitnami/apps
sudo chown -h -R root:daemon /opt/bitnami/apache2
sudo chown -h -R root:daemon /opt/bitnami/php

#Now update ownership for mysql
sudo chown -h -R mysql:daemon /opt/bitnami/mysql

#Make appropriate directories writable by group too where needed
sudo chmod -R 770 /opt/bitnami/apache2/var/
sudo chmod -R 770 /home/bitnami/apps/magento/htdocs/var
sudo chmod -R 770 /opt/bitnami/mysql

#Open up the ebay template dir to the all (any sftp access here is chrooted to /home/bitnami/apps/Magento/htdocs
sudo chmod 777 /home/bitnami/apps/magento/htdocs/app/design/ebay

#Lock down .ssh related stuff
sudo chown -R bitnami:bitnami /home/bitnami/.ssh
sudo chmod 700 /home/bitnami/.ssh
sudo chmod 644 /home/bitnami/.ssh/authorized_keys
sudo chmod 644 /home/bitnami/.ssh/id_rsa.pub
sudo chmod 600 /home/bitnami/.ssh/id_rsa

#Make apache2 and php-fpm members of codistouser group so that they can access uploaded templates
sudo usermod -G daemon,codistouser daemon


#Clear Magento caches
rm -rf /home/bitnami/apps/magento/htdocs/var/cache/*
rm -rf /home/bitnami/apps/magento/htdocs/var/session/*
