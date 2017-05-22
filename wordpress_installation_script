
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
echo "Subdomain Name: "
read -e sbname
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
mkdir -p /var/www/$sbname/public_html
cp -R wordpress/* /var/www/$sbname/public_html

#remove the wordpress folder
rm -rf wordpress

#create wp-config file
cp /var/www/$sbname/public_html/wp-config-sample.php /var/www/$sbname/public_html/wp-config.php

#configure database details with perl search and replace
perl -pi -e "s/database_name_here/$dbname/g" /var/www/$sbname/public_html/wp-config.php
perl -pi -e "s/username_here/$dbuser/g" /var/www/$sbname/public_html/wp-config.php
perl -pi -e "s/password_here/$dbpass/g" /var/www/$sbname/public_html/wp-config.php

#configure WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/$sbname/public_html/wp-config.php

#create an uploads folder and change permissions
mkdir /var/www/$sbname/public_html/wp-content/uploads
chmod 775 /var/www/$sbname/public_html/wp-content/uploads
chown -R apache:apache /var/www/$sbname/public_html
echo "Cleaning..."

#remove the zip file
rm latest.tar.gz*

# add VirtualHost lines to config file (sites-enabled needs a link to sites-available/domains.conf
echo "<VirtualHost *:80>
	ServerName www.$sbname.site.com
	ServerAlias $sbname.site.com
	DocumentRoot /var/www/$sbname/public_html
	ErrorLog /var/www/$sbname/error.log
	CustomLog /var/www/$sbname/custom.log combined
</VirtualHost>" >> /etc/httpd/sites-available/domains.conf

echo "========================="
echo "Installation is finished."
echo "========================="
fi
