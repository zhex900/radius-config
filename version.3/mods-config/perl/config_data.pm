package config_data;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw (DSN DBUSERNAME DBPASSWORD email_msg email_subject sms $timezone $MAILGUN_API $MAILGUN_URL $SENDER $BCC $SMS_API $SMSLOGIN $SMSPWD $SMSDEVICE);

our $timezone = 'Australia/Perth';

#Email settings
our $MAILGUN_API ='api:key-12838c7197b4cb35815e4aba7971d017';
our $MAILGUN_URL ='https://api.mailgun.net/v3/openvessels.org/messages';
our $SENDER ='wifi admin <wifi@openvessels.org>';
our $BCC ='jake.he@gmail.com';

#SMS gateway settings
our $SMS_API='http://smsgateway.me/api/v3/messages/send';
our $SMSLOGIN='zhex900@gmail.com';
our $SMSPWD ='fheman'; 
our $SMSDEVICE ='8969';

# MySQL database configurations
use constant DSN => "DBI:mysql:database=owums_db;host=mysql;port=3306";
use constant DBUSERNAME => "root";
use constant DBPASSWORD => "fheman";

sub email_msg {
	my (%arg) = @_;
	
	return qq{Hello $arg{user}, <P>This is just a friendly note to let you know that you\'ve used <b>$arg{used_data} ($arg{used_pct}%)</b> of your monthly quota of $arg{total_data}. You quota resets in <b>$arg{remaining} day(s)</b>, on: <b>$arg{reset_date}</b>. <P>To check your current usage please go to <a href="http://wifi.churchinperth.org">accounts</a>. <P>Much grace to you! <P>Jake He };
}

sub email_subject {
	my (%arg) = @_;

	return "$arg{used_pct}% Internet Quota Used! Resets on $arg{reset_date}.";
}

sub sms {
	my (%arg) = @_;
    
	return qq{Hello $arg{user},
    
	This is just a friendly note to let you know that you have used $arg{used_data} ($arg{used_pct}%) of your monthly quota of $arg{total_data}.
    
	You quota resets in $arg{remaining} day(s), on: $arg{reset_date}.
    
	Much Grace to you!
    
	Jake He}; 
}

1;
          
