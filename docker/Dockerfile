FROM phusion/baseimage:0.9.15

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Nginx-PHP Installation
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties debconf-utils

RUN add-apt-repository -y ppa:ondrej/php5
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/mysql-5.6
RUN apt-get update

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-tidy

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes git

RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade  -y --force-yes

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

RUN mkdir -p        /var/www
ADD build/default   /etc/nginx/sites-available/default
RUN mkdir           /etc/service/nginx
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#TODO create docker tags for different magento versions ... lets get this working first
ENV MAGENTO_VERSION magento-ce-1.9.0.1


#No prompt on initial clone
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

ENV CODISTOCONNECT_WORKSPACE=$HOME/Codisto

RUN mkdir -p $CODISTOCONNECT_WORKSPACE

RUN echo "Workspace is $CODISTOCONNECT_WORKSPACE"


#Set the workspace environment variable that MageTestStand setup.sh script will use
ENV WORKSPACE $CODISTOCONNECT_WORKSPACE
ENV MAGENTO_DB_USER=root
ENV MAGENTO_DB_PASS=magento

#Install mysql

RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password $MAGENTO_DB_PASS"'
RUN bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MAGENTO_DB_PASS"'

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes mysql-client-5.6 mysql-server-5.6

#Each run command is issued in a separate container so I need to start the mysql server and setup the db in one run transaction
ADD MageTestStand/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

RUN /tmp/setup.sh

#RUN curl -sSL https://raw.githubusercontent.com/CodistoConnect/CodistoConnectQA/bm_docker_compose/docker/MageTestStand/setup.sh | bash

#When container is created start ssh daemon
CMD /usr/sbin/sshd
EXPOSE 22


#TODO Even though it goes against docker philospohy I think I'll just package up mysql server inside this container too
#it allows me to completely install everything at BUILD time without relying on running mysql container
#yes people could use docker-composer , start both up and stuff gets installed but then they have to either commit after the install or wait for install each time a container is spun up.

#having it in a single container also enables docker run without relying on composer to help orchestrate everything or specifying links yourself at run