#!/bin/bash -e
clear
echo "================================================"
echo " WordPress Installatie Script"
echo "================================================"
echo "Database name: "
read -e dbname
echo "Database Gebruiker: "
read -e dbuser
echo "Database Wachtwoord: "
read -s dbpass
echo "Subdomeinname (bijvoorbeeld: transformers): "
read -e sbname
echo "Begin de installatie? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "================================================"
echo " Marijn zijn robot installeert WordPress voor u."
echo "================================================"

#download wordpress
wget https://wordpress.org/latest.tar.gz

#unzip wordpress
tar -zxvf latest.tar.gz

#kopieer bestanden een map omhoog
mkdir -p /var/www/$sbname/public_html
cp -R wordpress/* /var/www/$sbname/public_html

#verwijder de wordpress map
rm -rf wordpress

#wp-config maken
cp /var/www/$sbname/public_html/wp-config-sample.php /var/www/$sbname/public_html/wp-config.php

#stel database details in met perl zoek en vervang
perl -pi -e "s/database_name_here/$dbname/g" /var/www/$sbname/public_html/wp-config.php
perl -pi -e "s/username_here/$dbuser/g" /var/www/$sbname/public_html/wp-config.php
perl -pi -e "s/password_here/$dbpass/g" /var/www/$sbname/public_html/wp-config.php

#stel WP salts in
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/$sbname/public_html/wp-config.php

#maak uploads map en verander permissies
mkdir /var/www/$sbname/public_html/wp-content/uploads
chmod 775 /var/www/$sbname/public_html/wp-content/uploads
chown -R www-data:www-data /var/www/$sbname/public_html
echo "Cleaning..."

#verwijder zip file
rm latest.tar.gz*

# Voeg virtualhost toe aan domains.conf
echo "<VirtualHost *:80>
	ServerName www.$sbname.site.com
	ServerAlias $sbname.site.com
	DocumentRoot /var/www/$sbname/public_html
	ErrorLog /var/www/$sbname/error.log
	CustomLog /var/www/$sbname/custom.log combined
</VirtualHost>" >> test.txt

echo "========================="
echo "Installation is voltooid."
echo "========================="
fi
