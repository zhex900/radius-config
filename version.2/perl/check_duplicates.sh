#!/bin/bash

email=$1
subject=$2

#echo "INPUT: " $email " " $subject

queue=`/usr/sbin/postqueue -p | grep -c "$email"`
#echo "Queue: ("$queue")"
#no match in the print queue
if [ $queue -ne 0 ]; then
 echo true
else
	sentbefore=`grep -c $email /var/log/mail.log`
	#if email is not in the log return false.
	if [ $sentbefore -ne 0 ]; then
		#check this mail is already sent
		log=$(grep "$(grep "$email.*status=sent" /var/log/mail.log | cut -d ":" -f 4 )" /var/log/mail.log | grep -c "$subject")
		if [ $log -eq 0 ]; then
			echo false
		else
			echo true
		fi
	else
		echo false
	fi
fi
