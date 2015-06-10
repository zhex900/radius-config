# An implementation of FreeRADIUS Version 3, for an EAP/802.1x Wireless Network

##Features:
 * WIFI access using EAP authentication. WIFI users access the WIFI via user name and password.  
* Allocate monthly internet quota (include both uploads and downloads) to users. Disconnect user when quota is reached. 
 * Reset user's internet quota every month.
 * Users are managed via user groups. 
* Limit users to certain network access points
* Send user data usage warning messages via email and sms. (50%, 80% and 100%)

##Environment: 
*Email server:  mailgun, 
*SMS gateway: smsgateway.me. 
*NAS (dynamic ip address): Mikrotik 
*Freeradius host with static ip: CoreOS + Docker
*GUI: OWUMS

This guide is to show you how to configure free radius to implement the above features base upon the above environment. Any things beyond the aforementioned features and environment will be exceeding the scope of this guide. All the necessary configurations files are published here. You only need to change some basic settings to get it working in your environment. This guide is to show you how what these settings are and how to change it.

As a way of self documentation, this guide will also explain how the mentioned features are implemented. To understand how this

##Assumption


Freeradius does not include any graphical interface. It will be nice for users to see their network usage or change their password. Also user administrators need an initiative interface to manage its users. This need is meet by OWUMS. This free radius configuration is designed to work with OWUMS. For the OWUMS setup pleas refer this github. 

All the configuration is manually edited. If you want to modify any the features listed above you will need find your own solution. For example, if you want to have the internet quota to count only download traffic, you will need to change the code yourself. 

