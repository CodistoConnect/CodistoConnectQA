#!/bin/bash

PHPVERSION=$1

logger -s "Linting .."
logger -s "phpcs --standard=$HOME/approot/CodistoConnectQA/tasks/linting/codistostandard.xml --runtime-set testVersion $PHPVERSION -d date.timezone=Australia/Sydney $PLUGINPATH --report-width=200"

phpcs --standard="$HOME/approot/CodistoConnectQA/tasks/linting/codistostandard.xml" --runtime-set testVersion "$PHPVERSION" -d date.timezone=Australia/Sydney "$PLUGINPATH" --report-width=200
logger -s "Linting complete"

#make sure the last thing that is sent to STDOUT is the $PLUGINPATH so we can strip that off filenames when applying comments on github as they need to be relative to the repo
logger -s "Plugin path is $PLUGINPATH"
echo $PLUGINPATH
