#!/bin/bash
# Started via /opt/bitnami/scripts/init on demo instance
# Starts a bondi pool (which runs code from instancehelper.esp) with single child to monitor incoming requests (after being passed by apache proxy)
# for password changes and merchant state change

echo ""
echo "#########################################################################"
echo "#                                                                       #"
echo "#                      Starting instance helper (bondi)                 #"
echo "#                                                                       #"
echo "#########################################################################"
echo ""

SCRIPTLOCATION="/opt/bitnami/scripts/init"

sudo killall -9 sandringham bondi 1>/dev/null 2>&1

#lock down bondi pool to  bitnami home and run as bitnami user
sudo -u bitnami env BONDI_APPROOT=/home/bitnami/stack/ DEBUG=1 bondi -script instancehelper.esp -listen 6969 -service

#start sandringham wrapper over bash script to update DB
sudo -u bitnami sandringham -instancehelper $SCRIPTLOCATION/fcgiinstancehelper.sh \"{merchantid} {hostkey} {magentoadminpass}\" -listen 127.0.0.1 6970 -service

echo "Instance helper started!"