FROM phusion/baseimage:0.9.15

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

RUN add-apt-repository -y ppa:ondrej/php5
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/mysql-5.6
RUN apt-get update


RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-tidy vim curl wget build-essential python-software-properties debconf-utils git nginx

ENV MAGENTO_DB_USER=root
ENV MAGENTO_DB_PASS=magento


RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password $MAGENTO_DB_PASS"'
RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MAGENTO_DB_PASS"'

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes mysql-client-5.6 mysql-server-5.6

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

RUN mkdir -p        /var/www
ADD build/default   /etc/nginx/sites-available/default


#Why is all the following needed when there are by default

RUN mkdir           /etc/service/nginx
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#TODO create docker tags for different magento versions ... lets get this working first
ENV MAGENTO_VERSION magento-ce-1.9.0.1

#No prompt on initial clone
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

ENV CODISTOCONNECT_WORKSPACE=$HOME/Codisto
RUN mkdir -p $CODISTOCONNECT_WORKSPACE

#Set the workspace environment variable that MageTestStand setup.sh script will use
ENV WORKSPACE $HOME/Codisto/CodistoConnect


CMD "sh" "-c" "echo nameserver 8.8.8.8 > /etc/resolv.conf"

RUN mkdir "$CODISTOCONNECT_WORKSPACE/MageTestStand"
ENV BUILDENV "$CODISTOCONNECT_WORKSPACE/MageTestStand"

RUN mkdir "/Scripts"
ENV SCRIPTS "/Scripts"

#Each run command is issued in a separate container so I need to start the mysql server and setup the db in one run transaction
ADD MageTestStand/setup.sh $SCRIPTS/setup.sh
RUN chmod +x $SCRIPTS/setup.sh

ADD MageTestStand/install.sh $SCRIPTS/install.sh
RUN chmod +x $SCRIPTS/install.sh


#TODO change this to master when bm_travis_ci branch is merged
#Get codisto plugin (image layer fs here)
RUN git clone --progress --verbose --branch bm_travis_ci git://github.com/CodistoConnect/CodistoConnect.git $CODISTOCONNECT_WORKSPACE/CodistoConnect > /dev/null

ENV SKIP_CLEANUP 1

#Get MageTestStand (image fs layer here)
RUN git clone --progress --verbose https://github.com/AOEpeople/MageTestStand.git "${BUILDENV}" \
	&& cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

#Update composer to latest
RUN $BUILDENV/tools/composer.phar self-update


#Deploy db etc
RUN $SCRIPTS/setup.sh

RUN rm -R /var/www/html && ln -s /root/Codisto/MageTestStand/htdocs /var/www/html && chown -R www-data:www-data /var/www/html

RUN add-apt-repository -y ppa:supervisord-dev/ppa
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes supervisor
COPY build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80
CMD ["/usr/bin/supervisord"]