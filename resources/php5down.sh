#!/bin/bash
# by Ruben Barkow (rubo77) http://www.entikey.z11.de/
# GPL
# Originally Posted by Bachstelze http://ubuntuforums.org/showthread.php?p=9080474#post9080474
# OK, here's how to do the Apt magic to get PHP packages from the karmic repositories:

echo "Am I root?  "
if [ "$(whoami &2>/dev/null)" != "root" ] && [ "$(id -un &2>/dev/null)" != "root" ] ; then
  echo "  NO!

Error: You must be root to run this script.
Enter
sudo su
"
  exit 1
fi
echo "  OK";


#install aptitude before, if you don`t have it:
apt-get install aptitude
# or if you prefer apt-get use:
# alias aptitude='apt-get'

# finish all apt-problems:
aptitude update
aptitude -f install
#apt-get -f install

# remove all your existing PHP packages. You can list them with dpkg -l| grep php
PHPLIST=$(for i in $(dpkg -l | grep php|awk '{ print $2 }' ); do echo $i; done)
echo these pachets will be removed: $PHPLIST 
# you need not to purge, if you have upgraded from karmic:
aptitude remove $PHPLIST
# on a fresh install, you need purge:
# aptitude remove --purge $PHPLIST


#Create a file each in /etc/apt/preferences.d like this (call it for example /etc/apt/preferences.d/php5_2);
#
#Package: php5
#Pin: release a=karmic
#Pin-Priority: 991
#
#The big problem is that wildcards don't work, so you will need one such stanza for each PHP package you want to pull from karmic:

echo ''>/etc/apt/preferences.d/php5_2
for i in $PHPLIST ; do echo "Package: $i
Pin: release a=karmic
Pin-Priority: 991
">>/etc/apt/preferences.d/php5_2; done

# duplicate your existing sources.list replacing lucid with karmic and save it in sources.list.d:
#sed s/lucid/karmic/g /etc/apt/sources.list | sudo tee /etc/apt/sources.list.d/karmic.list

# better exactly only the needed sources, cause otherwise you can get a cachsize problem:
echo "# needed sources vor php5.2:
deb http://old-releases.ubuntu.com/ubuntu/ karmic main restricted
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic main restricted

deb http://old-releases.ubuntu.com/ubuntu/ karmic-updates main restricted
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic-updates main restricted

deb http://old-releases.ubuntu.com/ubuntu/ karmic universe
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic universe
deb http://old-releases.ubuntu.com/ubuntu/ karmic-updates universe
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic-updates universe

deb http://old-releases.ubuntu.com/ubuntu/ karmic multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic multiverse
deb http://old-releases.ubuntu.com/ubuntu/ karmic-updates multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ karmic-updates multiverse

deb http://old-releases.ubuntu.com/ubuntu karmic-security main restricted
deb-src http://old-releases.ubuntu.com/ubuntu karmic-security main restricted
deb http://old-releases.ubuntu.com/ubuntu karmic-security universe
deb-src http://old-releases.ubuntu.com/ubuntu karmic-security universe
deb http://old-releases.ubuntu.com/ubuntu karmic-security multiverse
deb-src http://old-releases.ubuntu.com/ubuntu karmic-security multiverse
" > /etc/apt/sources.list.d/karmic.list

aptitude update

apache2ctl restart

echo install new from karmic:
aptitude -t karmic install $PHPLIST

# at the end retry the modul libapache2-mod-php5 in case it didn't work the first time:
aptitude -t karmic install libapache2-mod-php5

apache2ctl restart
