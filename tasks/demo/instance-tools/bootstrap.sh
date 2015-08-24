#!/bin/bash

INIT_DIR=/opt/bitnami/scripts/init

cd "${INIT_DIR}"

Script[1]="fcgiinstancehelper.sh"
Script[2]="instancehelperstart.sh"
Script[3]="update_magento_baseurl.sh"
Script[4]="codisto_plugin.sh"
Script[5]="instancehelper.esp" # we dont want to execute this

InstallScript(){

	script="${1}"
	extension="${script##*.}"

	rm -f "${INIT_DIR}"/"${script}"
	wget -O "${INIT_DIR}"/"${script}" https://raw.githubusercontent.com/CodistoConnect/CodistoConnectQA/bm_perms/tasks/demo/instance-tools/"${script}"
	sudo chown root:bitnami "${INIT_DIR}"/"${script}"

	chmod 750 "${INIT_DIR}"/"${script}"
	if [ ${extension} = "sh" ]; then
		"${INIT_DIR}"/"${script}"
	fi

}

#Start pulling down all the scripts, make them executable and execute them. Background each one
for script in ${Script[@]}; do

	InstallScript "${script}"

done
