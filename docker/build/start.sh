echo "Starting services ..."
service ssh start &
service php5-fpm start &
service mysql start &
service nginx start &


