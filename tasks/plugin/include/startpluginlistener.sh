#!/bin/bash

#Start FastCGI wrappers over bash scripts
sandringham -pluginbuildmagento ${HOME}/approot/CodistoConnectQA/tasks/plugin/magento/plugin.sh \"{GITHUBTOKEN} {PLUGINPATH} {BUILDPATH} {TEST} {RESELLERKEY}\" \
				-pluginbuildmagento2 ${HOME}/approot/CodistoConnectQA/tasks/plugin/magento2/plugin.sh \"{GITHUBTOKEN} {PLUGINPATH} {BUILDPATH} {TEST} {RESELLERKEY}\" \
				-pluginbuildwoo ${HOME}/approot/CodistoConnectQA/tasks/plugin/woo/plugin.sh \"{GITHUBTOKEN} {PLUGINPATH} {BUILDPATH} {TEST} {RESELLERKEY} {SVNUSER} {SVNPASS}\"\
				-githelper ${HOME}/approot/CodistoConnectQA/include/githelper.sh \"{PATH} {SHA1} {STASHPOP} {TEST}\"\
				-listen 127.0.0.1 6971 -children 1 -service
sandringham -untar ${HOME}/approot/CodistoConnectQA/tasks/plugin/include/untar.sh \"{FILE} {DIR}\" -listen 127.0.0.1 6973 -children 1 -service
