#!/bin/sh
#
#**********************************
#Welcome to Accounting-123.com
#Licensed GPL v3 by  andre@andre.co.za
#built on Cubit support@cubit.co.za
#*********************************
#
####################################################
#Original script written for Cubit by Quintin Beukes
#Customised by Andre Coetzee Jan 2012
#Customised by Jean Moggess March 2012
#
#
###################################################
#Todo:
#Polish
#


if [ `id -u` != "0" ]; then
        echo "You need to be root"
        exit 1
fi

if [ "$1" != "" ]; then
        export APACHE_USER="$1"
else
        export APACHE_USER="nobody"
fi

# set a few variables
export whereis=whereis
export dialog=dialog
export grep=egrep
export docroot="/var/www/accounting-123"
export accroot="/var/www/accounting-123/htdocs"
export accounting123log="$accroot/accounting-123-install.log"


# notify of what we are going to do
$dialog --msgbox "\
               Accounting-123.com for Linux Installation\n\
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n\
The installation will setup the software for you. Please visit\n\
http://www.accounting-123.com if you require support or information\n\
\n\
- the Accounting-123 Team " \
10 62


mkdir /var/www/accounting-123
mkdir /var/www/accounting-123/htdocs

echo "Installing Accounting-123.com "`date` >$accounting123log


# extract files
$dialog --infobox "Installing Accounting-123.com Please wait..." 4 40
tar -jxpf ./data/acc.tar.bz2 -C $accroot 2>&1 >> $accounting123log
chown -R root:root $docroot 2>&1 >> $accounting123log
chmod -R 0644 /var/www/accounting-123/htdocs 2>&1 >> $accounting123log
for x in `find $docroot -type d`
do
        > $x/error_log
        chown $APACHE_USER:root $x/error_log 2>&1 >> $accounting123log
        chmod 0755 $x 2>&1 >> $accounting123log
        chmod 0640 $x/error_log 2>&1 >> $accounting123log
done

# create the default databases
if [ -x "/usr/bin/php" ]; then
        phpexe="/usr/bin/php"
fi

# check if extraction was succesful
if ! [ -f "$accroot/setup.php" ]; then
        $dialog --msgbox "Unknown error installing Accounting-123.com" 5 50
        exit
fi

#echo "${phpexe} -c /var/www/accounting-123.com/conf -f $accroot/transheks/daemon.php >>/var/log/acclogs/trh.log 2>&1 &" >> $accroot/start.sh


        $dialog --infobox "Creating databases. This could take 5 to 10 minutes. Please wait..." 4 40
        cd $accroot/dumping
        ${phpexe:-php} -f create_db.php 2>&1 >> $accounting123log
        mv $accroot/dumping $root >> $accounting123log

$dialog --msgbox "Accounting-123.com has successfully been installed" 5 50
