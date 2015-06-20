# An implementation of EAP/802.1x Wireless Network with FreeRADIUS

This is a FreeRADIUS configuration used to implement an EAP/802.1x wireless network. The following features are implemented. 

##Features:
* Wireless access using EAP authentication. Wireless users log onto the wireless network using username and password. Each user will have a its own profile. This profile contains: mobile number, email, first name, last name etc.   
* Each user's network traffic will be limited to monthly quota. This quota includes both uploads and downloads. Once the quota is reached, user will be disconnected from the network. 
* Network quota reset every month on a given date. For example, quota resets on 3rd of every month. 
* Users can be managed via user groups. This means that the same network policy can be applied to a group of users. A network policy could be like, 50 G of quota and reset on 3rd of every month.
* Restrict users to certain network access points. For example, the user group students can only have access to the NAS located in the science block. 
* Send user data usage warning messages via email and SMS. Once the user reached 50%, 80% or 100% of its quota, a warning message will be sent through both email and SMS.

##Environment: 
This is the environment used to implement the wireless network with EAP authentication. 
* Email server:  mailgun.
* SMS gateway: [smsgateway.me](smsgateway.me). 
* NAS (dynamic ip): Mikrotik.
* Radius server (static ip): FreeRADIUS Version 3 hosted with CoreOS + Docker.
* GUI for user management: [OWUMS](https://github.com/openwisp/OpenWISP-User-Management-System/wiki) hosted with CoreOS + Docker.

##Requirements:
* Debian baseed linux distros
* FreeRADIUS Version 2 or Version 3
* Cron
* Curl
* Perl

##Configuration:
To use this implementation a sets of configuration data needs to be correctly entered. The mysql sample configuration are at `radius-configdb/owums_sample.sql`. This sql schema can be use for both version 3 and 2. Email and SMS configuration are at `radius-config/version.3/mods-config/perl/config_data.pm`. In version 2, Email and SMS configuration are hard coded in `radius-config/version.2/perl/sendwarningmail.pl`.
###Radius Database:
These are the default values.

*Version 3: `radius-config/version.3/mods-available/sql`*
```
    driver = "rlm_sql_mysql"
    server = "mysql"
    port = 3306
    login = "radius"
    password = "radpass"
    radius_db = "owums_db"
```

*Version 2: `radius-config/version.2/sql.conf`*

```
    database = "owums_db"
    server = "mysql"
    port = 3306
    login = "radius"
    password = "radpass"
```
    
###Wireless Users:
*Table: `users`*
An user must belong to at least one user group. 

id | email       | crypted_password | active | given_name | surname | username| mobile_suffix|sentmail|
---|-------------| -----------------|--------|------------|---------|---------|--------------|--------|
10 | bob@mail.com| 7KU14qfW         | 1      | Bob        | Jones   | bob     | 0413129133   | 0      |

*Table: `radius_groups`*

id | name | 
---|------|
5  | staff|

Table: `radius_groups_users`

user_id	| radius_group_id|
--------|----------------|
10      | 5              |

###Network Information:
*Table: `nas`*

nasname	   | shortname	| type	   | secret |	nasidentifier	                    |
-----------|------------|----------|--------|-----------------------------------|
headoffice | headoffice	| mikrotik |radius	| 02-0C-42-B7-A9-5E:GRACE UPON GRACE|

* `nasname` is a description of the NAS.
* `shortname` shoudl be unique to identify the NAS.
*  `type` the type of the NAS.
*  `secret` radius server secret.
*  `nasidentifier` the mac-address and SSID. Note the format. 

###Network policy:
*Table: `radius_checks`*
This is to set the traffic quota and reset date. 

check_attribute	| op	| value	| radius_entity_id |	
----------------|-----|-------|------------------|
Reset-Date      |	:=	| 3	    | 5	               |
Total-Bytes	    | :=	|16106127360 |	5          |	

* `check_attribute` can be either `Reset-Date` or `Total-Bytes`.
* `Reset-Date` is the reset date of the month. It must be between 1-26.
* `Total-Bytes` is the total network quota in bytes (upload and download).
* `op` must be `:=`.
* `radius_entity_id` is the `radius_groups.id` of a group. For this example, it is group `staff`.
* `value` this is the value of the `check_attribute`.

*Table: `radius_replies`*

This radius implementation does send `Mikrotik-Total-Limit` and `Mikrotik-Total-Limit-Gigawords`in the reply attribute. These attributes should terminate the session when quota is reached. However Mikrotik NAS does not behave this way. I do not know why. To work around this problem, each session will be forced to reconnect after a period of time (1 hour). When an user reconnects, radius server will check the network usage and enforce the network policy. 

reply_attribute | op	| value	| radius_entity_id |	
----------------|-----|-------|------------------|
Session-Timeout	|:=	  | 10800 | 5                |

* `reply_attribute` can only be `Session-Timeout`.
* `radius_entity_id` is the `radius_groups.id` of a group. For this example, it is group `staff`.
* `value` this is the value of the `reply_attribute`.
* `Session-Timeout` this is the time limit of each session. The value is in seconds. 

*Table: `radsitegroup`*
This grant user group access to NAS. In this example, user group `staff` have access to NAS `headoffice`.

groupname | nasshortname |
----------|--------------|
staff     | headoffice   |

* `groupname` must be an existing group name in `radius_groups.name`.
* `nasshortname` must be an existing nas in `nas.shortname` or it can have the value `ALL`. `ALL` will grant access to all NAS in the `nas` table. 

###Email and SMS:
This is the email and sms configuration for version 3. This information is at `radius-config/version.3/mods-config/perl/config_data.pm`.

###Cron job:

##Docker 

##Build Docker image

*Version3:* 

1. Download the Dockerfile

   `curl -O https://raw.githubusercontent.com/zhex900/radius-config/master/version.3/Dockerfile`

2. Download the supervisord.conf.

   `curl -O https://raw.githubusercontent.com/zhex900/radius-config/master/version.3/supervisord.conf`

3. Build image.

   `docker build -t zhex900/freeradius3 .`

##Run the Docker image

`docker run -d --name freeradius3 --link mysql-service:mysql -p 1812:1812/udp -p 1813:1813/udp zhex900/freeradius3`

##Setup

###Change configuration from default
To make changes to the radius database settings and `config_data.pm`, you will need to get into the docker container. This is how you get into the container. Once you are in, all the freeradius configuration files are in `/etc/freeradius`. You can make changes as needed. 

`docker exec -it freeradius3 bash`

After you made the changes. You will need to restart the freeradius server. For this container freeradius is managed by `supervisord`.

Run `supervisorctl`

`supervisor> restart freeradius`

`supervisor> exit`

You can type `exit` to get out of the container. 

To save your changes to your image. 

`docker commit -m "updated mysql config and config_data.pm" freeradius3 zhex900/freeradius3`

###Setup database
````
% mysql -u root -ppassword -h mysql
mysql> CREATE DATABASE owums_db;
mysql> create user 'radius'@'%' IDENTIFIED BY 'radpass';
mysql> grant ALL PRIVILEGES on owums_db.* to 'radius'@'%';    
mysql> exit;
% wget https://raw.github.com/zhex900/radius-config/master/db/owums_sample.sql
% mysql -u radius -pradpass -h mysql owums_db < /etc/freeradius/db/owums_db_default.sql
````
* Create new radius user
* Create `owums_db` databse
* Copy the default database


This guide is to show you how to configure free radius to implement the above features base upon the above environment. Any things beyond the aforementioned features and environment will be exceeding the scope of this guide. All the necessary configurations files are published here. You only need to change some basic settings to get it working in your environment. This guide is to show you how what these settings are and how to change it.

As a way of self documentation, this guide will also explain how the mentioned features are implemented. To understand how this

##Assumption


Freeradius does not include any graphical interface. It will be nice for users to see their network usage or change their password. Also user administrators need an initiative interface to manage its users. This need is meet by OWUMS. This free radius configuration is designed to work with OWUMS. For the OWUMS setup pleas refer this github. 

All the configuration is manually edited. If you want to modify any the features listed above you will need find your own solution. For example, if you want to have the internet quota to count only download traffic, you will need to change the code yourself. 

