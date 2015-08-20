#!/bin/bash

INIT_DIR=/opt/bitnami/scripts/init

cd "${INIT_DIR}"

Script[1]="codisto_plugin.sh"
Script[2]="fcgiinstancehelper.sh"
Script[3]="instancehelperstart.sh"
Script[4]="update_magento_baseurl.sh"
Script[5]="instancehelper.esp" # we dont want to execute this

InstallScript(){

	script="${1}"
	extension="${script##*.}"

	sudo rm -f "${INIT_DIR}"/"${script}"
	sudo wget -O "${INIT_DIR}"/"${script}" https://raw.githubusercontent.com/CodistoConnect/CodistoConnectQA/master/tasks/demo/instance-tools/"${script}"

	if [ ${extension} = "sh" ]; then
		sudo chmod +x "${INIT_DIR}"/"${script}" \
 		&& sudo "${INIT_DIR}"/"${script}"
	fi

}

#Start pulling down all the scripts, make them executable and execute them. Background each one
for script in ${Script[@]}; do

	InstallScript "${script}"

done
