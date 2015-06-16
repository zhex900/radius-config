#!/usr/bin/perl
#
# Script to parse /var/log/maillog from postfix
# and send information to a .csv file.
# Information is sender, recipient, date,
# size and status of message.
#
# Author: Anton Lindström
# me@antonlindstrom.com
# Slightly updated by Suyash Jain

use strict;
use warnings;

my $maillog = "</var/log/mail.log";
my $csvfile = "logmail.csv";

# Open maillog.
open FILE, $maillog or die $!;
my @mailentries = <FILE>;
close(FILE);

# Define some global variables.
my (%from, %size, %to, %status, $postscsv);

foreach (@mailentries) {
# Next if the row does not contain a mailadress.
next if ($_ !~ /[\w\-\_\.]+\@[\w\-\_\.]+\.[a-z]+/);

# Collect data from log.
$_ =~
m/(\w+\s\d+\s\d+\:\d+\:\d+)\s.+\[[0-9]+\]\:\s([\w]+)\:(\s(from\=\<(.+)\>\,\ssize\=([0-9]+),)|(\sto\=\<([\w\-\_\.]+\@[\w\-\_\.]+\.[a-z]+)\>.+status\=(.+\))))/gi;

# Assign variables, $mailid is identifier for mail, therefor it can be used as key in hash.
# All posts are assigned to a hash with the $mailid as key.
my ($date, $rid) = ($1, $2);
($from{$rid}, $size{$rid}) = ($5, $6) if ($5 && $6);
($to{$rid}, $status{$rid}) = ($8, $9) if ($8 && $9);

print "date: $date";
# Formated csv-string, this is global!
$postscsv .= "$rid,$from{$rid},$to{$rid},$date,$size{$rid},$status{$rid}\n"
if ($date && $rid && exists($from{$rid}) && exists($size{$rid}) && exists($to{$rid}) && exists($status{$rid}) );
}
print $postscsv;
open(CSV, "> $csvfile");
print CSV $postscsv;
close(CSV);
