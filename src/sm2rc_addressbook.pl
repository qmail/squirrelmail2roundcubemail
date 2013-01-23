#!/usr/bin/perl
#
# Copyright (C) 2010 Alessandro De Zorzi - http://www.rhx.it/
# Copyright (C) 2013 Johannes Weberhofer - http://www.weberhofer.at/
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

# Require config file
require "dbconfig.pl";

use Text::CSV;
use DBI;
use File::Basename;

( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);

$mon  = sprintf( "%02d", $mon );
$mday = sprintf( "%02d", $mday );
$hour = sprintf( "%02d", $hour );
$min  = sprintf( "%02d", $min );
$sec  = sprintf( "%02d", $sec );

$changed =
    ( $year + 1900 ) . '-' . ( $mon + 1 ) . '-' . $mday . ' ' . $hour . ':' . $min . ':' . $sec;

my $csv =
  Text::CSV_XS->new( { sep_char => "|", 'always_quote' => 1, 'binary' => 1 } );

open( CSV, $ARGV[0] ) or die "open: $ARGV[0]: $!\n";

# Create MySQL connection
$dbh = DBI->connect( 'DBI:mysql:' . $db_name . ';host=' . $db_host,
	$db_user, $db_pass, { RaiseError => 1 } );

$username = substr( basename( $ARGV[0] ), 0, -8 );

# Try to find user code in roundcube
$sth =
  $dbh->prepare( "SELECT user_id FROM users WHERE LCASE(username)=LCASE('"
	  . $username
	  . "')" );
$sth->execute();
$result = $sth->fetchrow_hashref();

$user_id = $result->{user_id};

if ( !$user_id ) {
	print "New user " . $username . "\n";
	print "-------------------------------------" . "\n";
	$usrquery =
"INSERT INTO users ( `username`, `created`, `mail_host` ) VALUES ( LCASE('"
	  . $username . "'), '"
	  . $changed
	  . "', 'localhost') ";

	# Insert the contact
	$insusr = $dbh->prepare($usrquery);
	$insusr->execute();
	$sth->execute();
	$result  = $sth->fetchrow_hashref();
	$user_id = $result->{user_id};
}
$lines = 0;

while ( defined( $_ = <CSV> ) ) {
	s/"//g;
	s/\'/\_/g;
	s/\| /\|/g;

	$csv->parse($_)
	  or warn( "invalid CSV line: ", $csv->error_input(), "\n" ), next;
	my @fields = $csv->fields();

	$firstname = $fields[1];
	$surname   = $fields[2];
	$email     = $fields[3];

	if ( $fields[0] ) {
		$name = $fields[0];
	}
	elsif ( $fields[4] ) {
		$name = $fields[4];
	}
	else {
		$name = $firstname . ' ' . $surname;
	}

	# Check if countact already exists
	$sth =
	  $dbh->prepare( "SELECT contacts.* FROM contacts WHERE user_id='" 
		  . $user_id . "' AND LCASE(email)=LCASE('" . $email . "')" );
	  $sth->execute();
	$result = $sth->fetchrow_hashref();

	if ( !$result->{email} ) {
		# Insert the contact
		$query =
"INSERT INTO contacts ( `contact_id`,`changed`,`del`,`name`,`email`,`firstname`,`surname`,`vcard`,`user_id`) VALUES (NULL,'"
		  . $changed . "',0,'"
		  . $name
		  . "',LCASE('"
		  . $email . "'),'"
		  . $firstname . "','"
		  . $surname
		  . "',NULL,$user_id) ";
		$ins = $dbh->prepare($query);
		$ins->execute();
	}
	$lines = ( $lines + 1 );
}

$sth = $dbh->prepare( "SELECT COUNT(contact_id) AS nr FROM contacts WHERE user_id='" . $user_id . "'" );
$sth->execute();
$result = $sth->fetchrow_hashref();

print "User: " . $username . "\n";
print "SM contacts: " . $lines . "\n";
print "Import contacts: " . $result->{nr} . "\n";
print "-------------------------------------" . "\n";

close(CSV) or die "close: $ARGV[0]: $!\n";

# Close DB MySQL
$sth->finish;
$dbh->disconnect;