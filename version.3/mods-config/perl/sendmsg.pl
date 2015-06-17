# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
# Author: Jake He <zhex900@gmail.com>
# Date:   15 June 2015

#! usr/bin/perl 

#use strict;
use warnings;
use Number::Bytes::Human qw(format_bytes);
use POSIX qw(ceil);
use DBI;
use DateTime;
use config_data;

use vars qw(%RAD_CHECK %RAD_REPLY %RAD_REQUEST);
use constant RLM_MODULE_OK=>2;
use constant RLM_MODULE_UPDATED=>8;
use constant RLM_MODULE_REJECT=>0;
use constant RLM_MODULE_NOOP=>7;
use constant TESTMODE => "test";

# Declare all the variables
my @warnings = (0,50,80,100);
my $used_pct = 0;
my ($email, $user, $sentmail, $reset_date, $used_data, $total_data, $mobile, $i, $n);
$i=$n=0;

#testing mode
if ($ARGV[0] eq TESTMODE){
	use constant USED=>15999999997;
	use constant TOTAL=>19590999997;
	$used_pct     = ceil(USED/TOTAL*100);
	$email = 'jake.he@gmail.com';
	$user = ucfirst('bob');
	$sentmail = 50;
	$reset_date = nextresetdate(2);
	$used_data = format_bytes(USED); 
	$total_data = format_bytes(TOTAL); 
 	$mobile = '0433169143';
	
	print "###### Enable test mode! ######\n\n";
	email_warning();
	system ("cat /tmp/mailgun.queue");
}

# 
# This is called by the radius. 
#
sub authorize {

    $used_pct 
	= ceil(eval{$RAD_CHECK{'Used-Bytes'}/$RAD_CHECK{'Total-Bytes'}}*100);
    $email = $RAD_CHECK{'Email'};
    $user = ucfirst($RAD_REQUEST{'User-Name'});
    $sentmail = $RAD_CHECK{'Sent-Mail'};
    $mobile = $RAD_CHECK{'Mobile'};  
    $used_data = format_bytes($RAD_CHECK{'Used-Bytes'}, precision => 2);
    $total_data = format_bytes($RAD_CHECK{'Total-Bytes'}, precision => 2);
    $reset_date = nextresetdate($RAD_CHECK{'Reset-Date'}); #->add(days => 1);

    #Send warning emails 
    email_warning();

    return RLM_MODULE_NOOP;
}

sub email_warning{
    #initial value
    my $range = -1;
    my @w = @warnings;

    #find the range of the current usage.
    for($i=0;$i<@w;++$i) {
	#reset mail marker
	#the first range must be always have sent mail as zero.
	if( $used_pct >= $w[0] && $used_pct < $w[1] && $sentmail != 0 ){
	    #resets the sent mail marker
	    $range = 0;
	    last;
	}
	#Greater or equal to the last range.
	elsif ( $used_pct >= $w[$n-1] && $sentmail != $w[$n-1] ){
	    #make sure the user have no more data left.
	    if ( $RAD_CHECK{'Used-Bytes'} >= $RAD_CHECK{'Total-Bytes'} ){
		#debug print
		print $used_pct . " is range" . 
		    "(" . $w[$n-1]. "-". $w[$n-1].")\n";
		$range = $w[$n-1];
	    }
	    last;
	}
	elsif ( $used_pct >= $w[$i] && $used_pct < $w[add($i,$n)]
		&& $sentmail != $w[$i]){
	    #debug print
	    print "mail marker:(".$sentmail . ") " .$used_pct . "% is range" . 
		"(" . $w[$i]. "-". $w[add($i,$n)].")\n";
	    $range = $w[$i];
	    last;
	}
	else{#do nothing;
	}
    }

    #Send mail with range that is not the initial value
    if( $range != -1 ){
	#send mail to non zero range
	#range zero only need to be reset. No mail is nees to be sent
	if ($range !=  0){
	    mysendmail();
	}
	#set sent mail marker
	mailmarker($range);
    }
}

#
#To avoid sending the multiple warning mails. A marker 'sentmail' is used in 
#the users table in radius database. sentmail records the warning mails that
#has been sent in a range. For example, if a warning email that was sent at the 
#range of 80%, sentmail's value will be 80.
#
sub mailmarker{

    #get first parameter
    my $range = shift;
    # connect to MySQL database
    my %attr = ( PrintError=>0, RaiseError=>1);
    my $dbh = DBI->connect(DSN,DBUSERNAME,DBPASSWORD, \%attr);
    #update statement
    my $sql = "UPDATE `users` SET `sentmail`=$range " . 
	"WHERE `username`=lower('$user');";
    $dbh->do($sql);
    $dbh->disconnect;
}

#send warning mail
sub mysendmail{
 
    #work out the number of days until the next reset  
    my $today = DateTime->now()->set_time_zone('Australia/Perth');#$timezone);
    my $remaining = $today->delta_days($reset_date)->in_units('days');
    my $reset_date = $reset_date->dmy;

    my %arg = ('user'=>$user, 'used_data'=>$used_data, 'used_pct'=>$used_pct, 'reset_date'=>$reset_date, 'total_data'=>$total_data, 'remaining'=>$remaining);
    my $subject = email_subject(%arg); 
    my $msg = email_msg(%arg);
    my $sms = sms(%arg);
   
    open(my $fh, '>>', '/tmp/mailgun.queue');
 
    # set the email in the queue file.   
    print $fh "curl -s --user \'$MAILGUN_API\' $MAILGUN_URL -F from=\'$SENDER\' -F to=$email -F bcc=$BCC -F subject=\'$subject\' -F html=\"$msg\"\n"; 
    # set the sms in the queue file.
    print $fh "curl -s \'$SMS_API\' -F email=\'$SMSLOGIN\' -F password=\'$SMSPWD\' -F device=\'$SMSDEVICE\' -F number=$mobile -F message=\"$sms\"\n";
   
    close $fh;
}

#helper function
sub add{
    my $m=0;
    ($i, $m) = @_;
    if ($i==$m-1){
	return $i;
    }else{
	return $i+1;
    }
}

#this is to avoid illegal division by zero error
sub divide{
    my ( $divided, $divisor ) = @_;
    if ( $divisor != 0 ){
	return $divided/$divisor;
    }
    else{
	return 0;
    }
}

#give a date find the next month.
sub nextresetdate{
    my $reset_date = $_[0];
    # current date                                                              
    my $today = DateTime->now(time_zone=>'local');

    #if current date is ahead of the reset date                                 
    #set the month as next month                                                
    if ( $today->day() >= $reset_date ){
        $today->add(months=>+1); 
        $today->set_day($reset_date);
    }
    else{
        $today->set_day($reset_date);
    }
    return $today;
}

