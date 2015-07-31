#Placeholder for update detection code
#When the plugin is installed it will set the codisto_version in core_resource (check this again)
#it will also set codisto_affiliate in core_resource(wherever codisto_version) is

#every hour or some sort of delta it will make a web request to qa.codisto.com/plugin/check?version=blah&affiliate=blah
# if there is indeed a plugin it will download it with wget into /tmp/$RANDOM
#then it will install using something like the following


#cd into magento dir here ... find a nice way to locate with php if possible.. try locate then find perhaps
#sudo updatedb

#./mage uninstall community CodistoConnect
#wget -O plugin.tgz https://codisto.com/plugin/getstable
#./mage install-file plugin.tgz
#rm plugin.tgz
