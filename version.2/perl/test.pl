#! usr/bin/perl 

#use strict;
# use ...
# This is very important!
#use vars qw(%RAD_CHECK %RAD_REPLY %RAD_REQUEST);
use constant RLM_MODULE_OK=>2;
use constant RLM_MODULE_UPDATED=>8;
use constant RLM_MODULE_REJECT=>0;
use constant RLM_MODULE_NOOP=>7;
use Number::Bytes::Human qw(format_bytes);
use MIME::Lite;
use POSIX qw(ceil);
use DBI;
use DateTime;

my @warnings = (0,50,80,100);
my $used_pct = 0;
my $email;
my $user;
my $sentmail;
#my $reset_date;
my $used_data;
my $total_data;

#testing
use constant USED=>19000999997;
use constant TOTAL=>19590999997;
my $used_pct  = ceil(USED/TOTAL*100);
my $email = 'zhex900@gmail.com';
my $user = ucfirst('jake');
my $sentmail = 50;
my $reset_date = nextresetdate(4);
my $used_data = format_bytes(USED); 
my $total_data = format_bytes(TOTAL); 

# MySQL database configurations
my $dsn = "DBI:mysql:owums_db";
my $dbusername = "owums_db";
my $dbpassword = "fheman";

#testing
authorize();

sub authorize {

   # $used_pct 
#	= ceil(eval{$RAD_CHECK{'Used-Bytes'}/$RAD_CHECK{'Total-Bytes'}}*100);
#    $email = $RAD_CHECK{'Email'};
 #   $user = ucfirst($RAD_REQUEST{'User-Name'});
  #  $sentmail = $RAD_CHECK{'Sent-Mail'};
   # #$reset_date = nextresetdate($RAD_CHECK{'Reset-Date'});
   # $used_data = format_bytes($RAD_CHECK{'Used-Bytes'});
   # $total_data = format_bytes($RAD_CHECK{'Total-Bytes'});

    #Send warning emails 
   print "Try to send warning email\n";
   email_warning();
   # $RAD_CHECK{'Email'}=$used_pct;
    return RLM_MODULE_NOOP;
}

sub email_warning{
    #initial value
    local $range = -1;
    local @w = @warnings;

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

print "range: $range\n";
    #Send mail with range that is not the initial value
    if( $range != -1 ){
	#send mail to non zero range
	#range zero only need to be reset. No mail is nees to be sent
	
	if ($range !=  0){
	    mysendmail();
	}
	#set sent mail marker
	print "call mailmarker ($range)";
mysendmail();
mysendmail();
mysendmail();
mysendmail();
mysendmail();	
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
    my $dbh = DBI->connect($dsn,$dbusername,$dbpassword, \%attr);
    #update statement
    my $sql = "UPDATE `users` SET `sentmail`=$range " . 
	"WHERE `username`=lower('$user');";
    $dbh->do($sql);
    $dbh->disconnect;
}

#send warning mail
sub mysendmail{
	print ("generating email\n");
    #work out the number of days until the next reset
    my $today = DateTime->now(time_zone=>'local');
    my $reset_date = nextresetdate(5); #$RAD_CHECK{'Reset-Date'});
    my $remaining = $today->delta_days($reset_date)->in_units('days');
    $reset_date = $reset_date->dmy;
    my $msg = qq{ 
Hi $user,

<P>This is just a friendly note to let you know that you\'ve used 
<b>$used_data ($used_pct%)</b> of your monthly quota of $total_data. 
You quota resets in <b>$remaining day(s)</b>, just after midnight on: 
<b>$reset_date</b>.

<P>To check your current usage please go to 
<a href="http://churchinperth.no-ip.biz/daloradius/daloradius-users/index.php
">toolbox</a>.

<P>Much grace to you!

<P>Jake He
};

local $subject = "$used_pct% Quota! Resets on $reset_date";

    my $mime = MIME::Lite->new(
    'From'    => $email,
    'To'      => $email,
    'Subject' => $subject,
    'Type'    => 'text/html',
    'Data'    => $msg,
	);
print $subject;
    chomp($d = `sh ./check_duplicates.sh $email "$subject"`);
    print "check: $d\n";
    if ($d eq "true") {
	print "SKIP mail!\n";
    }else{
      	print "Send mail\n";
        $mime->send() or die "Failed to send mail\n";
    }
}

#helper function
sub add{
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
