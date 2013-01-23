squirrelmail2roundcubemail
==========================

Migrate Squirrelmail addressbooks to Roundcubemail MySQL accounts.

To import the squirrelmail addressbooks from /var/lib/squirrelmail/prefs/
into the new MySQL Database used from Roundcubemail, do the following steps:

* Install Roundcubemail and initialize the database
* Set the database-configuration in dbconfig.pl
* execute squirrelmail2roundcubemail.sh

The origin addressbook-path is hard-coded in squirrelmail2roundcubemail.sh

RPM-packages for different systems can be found at the opensuse build server
at http://download.opensuse.org/repositories/home:/weberho:/qmailtoaster/

Many thanks to Alessandro De Zorzi, who wrote the original code for this tool.