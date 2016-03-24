#!/bin/bash
logger -s "Codisto Connect for Magento 2 plugin build commencing ..."

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
CONFIGFILE="${PLUGINPATH}/code/community/Codisto/Sync/etc/config.xml"
GITHUBARTIFACT="CodistoConnect-Magento2"
GITHUBEXTENSION=".zip"
