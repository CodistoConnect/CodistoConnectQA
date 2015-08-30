#!/bin/bash

# Started via /opt/bitnami/scripts/init on demo instance
# Updates Magento base_urls

echo "" 
echo "#########################################################################" 
echo "#                                                                       #" 
echo "#                       Updating Magento base_url                       #" 
echo "#                                                                       #" 
echo "#########################################################################" 
echo "" 


#Can only do forward dns lookups so lookup all entries below and find the matching one to external IP

MagentoPWD='$HOME/apps/magento/htdocs'
ExternalIP=`dig +short myip.opendns.com @resolver1.opendns.com`

Domain[1]="demo1.codisto.com"
Domain[2]="demo2.codisto.com"
Domain[3]="demo3.codisto.com"
Domain[4]="demo4.codisto.com"
Domain[5]="demo5.codisto.com"

for domain in ${Domain[@]}; do
        IP=`dig ${domain} a +short` 
        if [ $IP == $ExternalIP ]; then
                MatchingDomain=${domain}
        fi
done

if [ -z "${MatchingDomain+xxx}" ]; then
        echo "No matching A record found on codisto.com for IP :q
        " $ExternalIP
else
        echo "Matching A record is " $MatchingDomain
        echo "Updating Baseurl in Magento"
        /opt/bitnami/mysql/bin/mysql -u root -p\!Codisto69 -e "USE bitnami_magento; UPDATE core_config_data SET VALUE = 'http://${MatchingDomain}/' WHERE path = 'web/unsecure/base_url'";
        /opt/bitnami/mysql/bin/mysql -u root -p\!Codisto69 -e "USE bitnami_magento; UPDATE core_config_data SET VALUE = 'https://${MatchingDomain}/' WHERE path = 'web/secure/base_url'";
        echo "All done"
fi

