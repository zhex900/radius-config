# An implementation of EAP/802.1x Wireless Network with FreeRADIUS Version 3

This repository contains all the configuration files for FreeRADIUS v. 3 (FR3). FR3 is use to implement an EAP/802.1x wireless network. FR3 is configured to implement the following features. 

##Features:
* Wireless access using EAP authentication. Wireless users log onto the WIFI using username and password. Each user will have a its own profile. This profile contains: mobile number, email, first name, last name etc.   
* Each user's network traffic will be limited to monthly quota. This includes both uploads and downloads. Once the quota is reached, user will be disconnected from the network. An user can use access the wireless network, when the quota is not reached.
* Reset user's network quota every month.
* Users can be managed via user groups. This means that the same network policy can be applied to a group of users. A network policy could be like, 50 G of quota and reset on 3rd of every month.
* Restrict users to certain network access points.
* Send user data usage warning messages via email and SMS. Once the user reached 50%, 80% or 100% of its quota, a warning message will be sent through both email and SMS.

This is the environment used to implement the wireless network with EAP authentication.  
##Environment: 
* Email server:  mailgun, 
* SMS gateway: [smsgateway.me](smsgateway.me). 
* NAS (dynamic ip): Mikrotik
* Radius server (static ip): FreeRADIUS Version 3 hosted with CoreOS + Docker.
* GUI for user management: [OWUMS](https://github.com/openwisp/OpenWISP-User-Management-System/wiki) hosted with CoreOS + Docker.

##Usage:

This guide is to show you how to configure free radius to implement the above features base upon the above environment. Any things beyond the aforementioned features and environment will be exceeding the scope of this guide. All the necessary configurations files are published here. You only need to change some basic settings to get it working in your environment. This guide is to show you how what these settings are and how to change it.

As a way of self documentation, this guide will also explain how the mentioned features are implemented. To understand how this

##Assumption


Freeradius does not include any graphical interface. It will be nice for users to see their network usage or change their password. Also user administrators need an initiative interface to manage its users. This need is meet by OWUMS. This free radius configuration is designed to work with OWUMS. For the OWUMS setup pleas refer this github. 

All the configuration is manually edited. If you want to modify any the features listed above you will need find your own solution. For example, if you want to have the internet quota to count only download traffic, you will need to change the code yourself. 

