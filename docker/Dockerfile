FROM phusion/baseimage:0.9.15

MAINTAINER Brad McCormack <bmccormack@codisto.com>

# Ensure UTF-8
RUN locale-gen en_AU.UTF-8
ENV LANG       en_AU.UTF-8
ENV LC_ALL     en_AU.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

#Add thirdy party repos and update the system
RUN add-apt-repository -y ppa:ondrej/php5 \
	&& add-apt-repository -y ppa:nginx/stable \
	&& add-apt-repository -y ppa:ondrej/mysql-5.6 \
	&& add-apt-repository -y ppa:supervisord-dev/ppa \
	&& add-apt-repository ppa:saiarcot895/myppa \
	&& apt-get update


RUN apt-get install apt-fast -y

#Tweak apt-fast
RUN sed -E -i "s/_MAXNUM=([0-9]+)/_MAXNUM=16/" /etc/apt-fast.conf \
	&& sed -i "s/#MIRRORS=( 'none' )/MIRRORS=( 'us-east-1.ec2.archive.ubuntu.com\/ubuntu,us-east-2.ec2.archive.ubuntu.com\/ubuntu,us-west-1.ec2.archive.ubuntu.com\/ubuntu' )/" /etc/apt-fast.conf

#Install required software
RUN DEBIAN_FRONTEND="noninteractive" apt-fast install -y --force-yes php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-tidy vim curl wget build-essential python-software-properties debconf-utils git nginx supervisor

RUN apt-fast upgrade -y --force-yes

#Set default password for mysql and install it
ENV MAGENTO_DB_USER=root
ENV MAGENTO_DB_PASS=magento

RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password $MAGENTO_DB_PASS"' \
	&& bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MAGENTO_DB_PASS"'
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes mysql-client-5.6 mysql-server-5.6

#Update various configuration files
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

#Clean up after install
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#No prompt on initial clones
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

ENV CODISTOCONNECT_WORKSPACE=$HOME/Codisto
RUN mkdir -p $CODISTOCONNECT_WORKSPACE

#Set the workspace environment variable that MageTestStand setup.sh script will use
ENV WORKSPACE $HOME/Codisto/CodistoConnect

ENV MAGENTO_VERSION magento-ce-1.9.0.1-speedupmate

RUN mkdir "$CODISTOCONNECT_WORKSPACE/MageTestStand"
ENV BUILDENV "$CODISTOCONNECT_WORKSPACE/MageTestStand"

#Add build scripts
RUN mkdir "/Scripts"
ENV SCRIPTS "/Scripts"
ADD MageTestStand/setup.sh $SCRIPTS/setup.sh
ADD MageTestStand/install.sh $SCRIPTS/install.sh
ADD MageTestStand/tests.sh $SCRIPTS/tests.sh
RUN chmod +x $SCRIPTS/setup.sh && chmod +x $SCRIPTS/install.sh && chmod +x $SCRIPTS/tests.sh

#Get codisto plugin
RUN git clone --progress --verbose --branch master git://github.com/CodistoConnect/CodistoConnect.git $CODISTOCONNECT_WORKSPACE/CodistoConnect > /dev/null

ENV SKIP_CLEANUP 1

#Get MageTestStand
RUN git clone --progress --verbose https://github.com/AOEpeople/MageTestStand.git "${BUILDENV}" \
	&& cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

ADD MageTestStand/.n98-magerun.yaml /etc/n98-magerun.yaml

#cd $BUILDENV

RUN "bash" "-c" "echo nameserver 8.8.8.8 > /etc/resolv.conf"

#Update composer to latest
RUN $BUILDENV/tools/composer.phar self-update

#Deploy db etc
RUN $SCRIPTS/setup.sh


#Set up nginx related configuration

#Add our Magento configuration
ADD build/nginx/magento	/etc/nginx/sites-available/magento

#Enable our Magento configuration, make sure /var/www (server root) is sym linked to magento directory
RUN rm /etc/nginx/sites-enabled/default \
	&& ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled/magento \
	&& ln -sf $BUILDENV/htdocs /var/www/magento \
	&& chown -R root:www-data /var/www/magento \
	&& chmod 750 -R /var/www/magento \
	&& chown -R root:www-data /root \
	&& chmod 750 -R /root

#Add the plugin updater bash script
ADD build/codisto_update /usr/bin/codisto_update
RUN chmod +x /usr/bin/codisto_update
RUN /usr/bin/codisto_update

#Tests 
RUN $SCRIPTS/tests.sh


#Copy over supervisor configuration
COPY build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
