#
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
# Date: 17 June 2015

package config_data;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw ($DB $DB_HOST $DB_PORT $DBUSERNAME $DBPASSWORD email_msg email_subject sms $timezone $MAILGUN_API $MAILGUN_URL $SENDER $BCC $SMS_API $SMSLOGIN $SMSPWD $SMSDEVICE);

our $timezone = 'Australia/Perth';

#Email settings
our $MAILGUN_API ='';
our $MAILGUN_URL ='https://api.mailgun.net/v3/churchinperth.org/messages';
our $SENDER ='no-reply@churchinperth.org';
our $BCC ='wendygoh123@yahoo.com';

#SMS gateway settings
our $SMS_API='http://smsgateway.me/api/v3/messages/send';
our $SMSLOGIN='';
our $SMSPWD =''; 
our $SMSDEVICE ='';

# MySQL database configurations
our $DB = 'owums_db';
our $DB_HOST = 'mysql';
our $DB_PORT = '3306';
our $DBUSERNAME = 'radius';
our $DBPASSWORD = 'radpass';

sub email_msg {
	my (%arg) = @_;
	
	return qq{
Hello $arg{user}, 
<P>
This is just a friendly note to let you know that you\'ve used <b>$arg{used_data} ($arg{used_pct}%)</b> of your monthly quota of $arg{total_data}. You quota resets in <b>$arg{remaining} day(s)</b>, on: <b>$arg{reset_date}</b>. 
<P>
To check your current usage please go to <a href="http://wifi.churchinperth.org">accounts</a>. 
<P>
Much grace to you! 
<P>
Corporate Living Serving Ones };
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
    
Corporate Living Serving Ones}; 
}

1;
          
