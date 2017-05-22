#Before the execution of this script, change the DNS records of the site towards the webserver
#!/bin/bash -e
clear
echo "================================================"
echo " WordPress Installation Script"
echo "================================================"
echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass
echo "Domain name: "
read -e dmname
echo "Start the installation? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "================================================"
echo " A Robot is installing WordPress for you."
echo "================================================"

#download wordpress
curl -O https://wordpress.org/latest.tar.gz

#unzip wordpress
tar -zxvf latest.tar.gz

#copy the files to another folder
mkdir -p /var/www/$dmname/public_html
cp -R wordpress/* /var/www/$dmname/public_html

#remove the wordpress folder
rm -rf wordpress

#create wp-config file
cp /var/www/$dmname/public_html/wp-config-sample.php /var/www/$dmname/public_html/wp-config.php

#configure database details with perl search and replace
perl -pi -e "s/database_name_here/$dbname/g" /var/www/$dmname/public_html/wp-config.php
perl -pi -e "s/username_here/$dbuser/g" /var/www/$dmname/public_html/wp-config.php
perl -pi -e "s/password_here/$dbpass/g" /var/www/$dmname/public_html/wp-config.php

#configure WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/$dmname/public_html/wp-config.php

#create an uploads folder and change permissions
mkdir /var/www/$dmname/public_html/wp-content/uploads
chmod 775 /var/www/$dmname/public_html/wp-content/uploads
chown -R apache:apache /var/www/$dmname/public_html
echo "Cleaning..."
#replace apache:apache with www-data:www-data if you're running ubuntu server

#remove the zip file
rm latest.tar.gz*

# add VirtualHost lines to config file (sites-enabled needs a link to sites-available/domains.conf
echo "<VirtualHost *:80>
	ServerName www.$dmname.com
	ServerAlias $dmname.com
	DocumentRoot /var/www/$dmname/public_html
	ErrorLog /var/www/$dmname/error.log
	CustomLog /var/www/$dmname/custom.log combined
</VirtualHost>" >> /etc/httpd/sites-available/domains.conf
# replace /etc/httpd/sites-available/domains.conf  with /etc/apache2/sites-available/000-default.conf if you're running Ubuntu server

echo "========================="
echo "Installation is finished."
echo "========================="
fi
