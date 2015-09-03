#! usr/bin/perl 
# This will be runned once a month
#use strict;
use warnings;
#use Number::Bytes::Human qw(format_bytes);
#use POSIX qw(ceil);
use DBI;
#use DateTime;
use lib '/etc/freeradius/mods-config/perl/';
use config_data;

# connect to MySQL database
my %attr = ( PrintError=>0, RaiseError=>1);
my $dbh = DBI->connect("DBI:mysql:database=".$DB.";host=".$DB_HOST.";port=".$DB_PORT.";",$DBUSERNAME,$DBPASSWORD, \%attr);

#delete all radacct records two months ago. 
my $sql = "DELETE FROM `radacct` WHERE DATE_FORMAT( `AcctStartTime`, '%Y/%m/01' ) <  DATE_FORMAT( CURRENT_DATE - INTERVAL 2 MONTH, '%Y/%m/01' ) ;";
my $del_sessions = "DELETE FROM `sessions` WHERE DATE_FORMAT( `created_at`, '%Y/%m/01' ) <  DATE_FORMAT( CURRENT_DATE - INTERVAL 2 MONTH, '%Y/%m/01' ) ;";
my $radpostauth = "DELETE FROM `radpostauth` WHERE DATE_FORMAT( `authdate`, '%Y/%m/01' ) <  DATE_FORMAT( CURRENT_DATE - INTERVAL 2 MONTH, '%Y/%m/01' ) ;";
$dbh->do($sql);
$dbh->do($del_sessions);
$dbh->do($radpostauth);
$dbh->disconnect;
