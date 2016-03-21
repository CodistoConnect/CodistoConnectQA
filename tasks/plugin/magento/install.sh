#!/bin/bash

#Attempt to use locate as it is faster (if Magento is in the database
MAGEPATH=$(locate -b '\mage' | while IFS= read -r line; do [[ -x "$line" ]] && [[ -f "$line" ]] && echo "$line"; done)

#Not in the database so just use find
if [ -z $MAGEPATH ]; then
        MAGEPATH=$(find / -type f -executable -name mage 2>/dev/null)
fi

if [ -n $MAGEPATH ]; then

        #strip out directory
        MAGEPATH=${MAGEPATH%/*}

        cd "$MAGEPATH"
        rm app/design/ebay/README 1>/dev/null 2>&1
        ./mage uninstall community CodistoConnect 1>/dev/null 2>&1 && {PLUGIN_FETCH} && ./mage install-file plugin.tgz && rm plugin.tgz
fi
