#------------------------------------------------
#   INSTALACAO AUTOMATIZADA PHPMYADMIN NO ORACLE LINUX 8
#------------------------------------------------
#
#  Desenvolvido por: Service TIC Solucoes Tecnologicas
#            E-mail: contato@servicetic.com.br
#              Site: www.servicetic.com.br
#          Linkedin: https://www.linkedin.com/company/serviceticst
#          Intagram: https://www.instagram.com/serviceticst
#          Facebook: https://www.facebook.com/serviceticst
#           Twitter: https://twitter.com/serviceticst
#           YouTube: https://youtube.com/c/serviceticst
#            GitHub: https://github.com/serviceticst
#
#              Blog: https://servicetic.com.br/metabase-instalacao-automatizada-no-oracle-linux-8
#           YouTube: https://www.youtube.com/watch?v=p4M2Uemh2eE
#-------------------------------------------------
#
clear
echo "#--------------------------------------------------------#"
echo            "INSTALACAO PACOTES E REPOSITORIOS"
echo "#--------------------------------------------------------#"
dnf -y install httpd
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf module enable php:remi-8.0 -y
dnf -y install yum-utils zip unzip wget -y
dnf update -y
dnf install php php-cli php-fpm php-mysql php-mysqlnd zip unzip -y
clear
echo "#--------------------------------------------------------#"
echo                "BAIXANDO O PHPMYADMIN"
echo "#--------------------------------------------------------#"
cd /usr/share
curl -O https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip
unzip phpMyAdmin-5.2.0-all-languages.zip
mv phpMyAdmin-5.2.0-all-languages phpmyadmin
rm -Rf phpMyAdmin-5.2.0-all-languages.zip
clear
echo "#--------------------------------------------------------#"
echo           "CRIANDO ARQUIVO DE CONFIGURACAO WEB"
echo "#--------------------------------------------------------#"
cat <<EOF | tee /etc/httpd/conf.d/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin/>
   AddDefaultCharset UTF-8

<IfModule mod_authz_core.c>
     # Apache 2.4
     <RequireAny>
       Require all granted
     # Require ip 127.0.0.1 0.0.0.0/
     # Require ip ::1
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     # Apache 2.2
     Order Deny,Allow
     Deny from All
     Allow from all
    # Allow from 127.0.0.1 0.0.0.0
    # Allow from ::1
   </IfModule>


#   Require local
</Directory>

<Directory /usr/share/phpmyadmin/setup/>
   Require local
</Directory>

# These directories do not require access over HTTP - taken from the original
# phpMyAdmin upstream tarball
#
<Directory /usr/share/phpmyadmin/libraries/>
    Require all denied
</Directory>

<Directory /usr/share/phpmyadmin/templates/>
    Require all denied
</Directory>

<Directory /usr/share/phpmyadmin/setup/lib/>
    Require all denied
</Directory>

<Directory /usr/share/phpmyadmin/setup/frames/>
    Require all denied
</Directory>

# This configuration prevents mod_security at phpMyAdmin directories from
# filtering SQL etc.  This may break your mod_security implementation.
#
#<IfModule mod_security.c>
#    <Directory /usr/share/phpmyadmin/>
#        SecRuleInheritance Off
#    </Directory>
#</IfModule>
#<VirtualHost *:80>
#
#  DocumentRoot /usr/share/phpmyadmin
#  ServerName phpmyadmin.example.com
#  ServerAlias www.phpmyadmin.example.com
#
#</VirtualHost>
EOF
clear
echo "#--------------------------------------------------------#"
echo        "APLICANDO PERMISSOES E AJUSTANDO ARQUIVOS"
echo "#--------------------------------------------------------#"
chown -Rf root:root /usr/share/phpmyadmin
chmod -Rf 755 /usr/share/phpmyadmin
mkdir /usr/share/phpmyadmin/tmp
chmod -Rf 777 /usr/share/phpmyadmin/tmp
cd /usr/share/phpmyadmin
cp config.sample.inc.php config.inc.php
echo "$cfg['blowfish_secret'] = 'ctyRoGmbc9{8IZr323xYcSN]0s)r$9b_JUnb{~Xz'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */" >> /usr/share/phpmyadmin/config.inc.php  
sed -i '154s/^/$cfg/' /usr/share/phpmyadmin/config.inc.php
clear
echo "#--------------------------------------------------------#"
echo                   "LIBERANDO FIREWALL"
echo "#--------------------------------------------------------#"
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
clear
echo "#--------------------------------------------------------#"
echo                   "REINCIANDO APACHE"
echo "#--------------------------------------------------------#"
systemctl restart httpd
echo FIM