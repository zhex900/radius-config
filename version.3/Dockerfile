FROM ubuntu:trusty
MAINTAINER Jake He "zhex900@gmail.com"

EXPOSE 1812/udp
EXPOSE 1813/udp

#install dependencies
RUN apt-get update && \
        apt-get -yq install libyubikey0 libtalloc2 diffstat cron supervisor curl git vim libperl5.18 dpkg-dev libssl-dev ssl-cert libnumber-bytes-human-perl libdbi-perl libdbd-mysql-perl libdatetime-perl && apt-get -y build-dep freeradius && \
        git clone https://zhex900@bitbucket.org/zhex900/freeradius3.0.8.git /tmp/freeradius && \
        cd /tmp/freeradius && \
        dpkg -i ./*.deb && \
        git clone https://github.com/zhex900/radius-config.git /tmp/config_freeradius && \
        cp -r /tmp/config_freeradius/version.3/* /etc/freeradius/ && \
        apt-get -yq purge manpages make libpython2.7-dev vim-runtime git gcc-4.8 cpp-4.8 locales libperl-dev  &&\
        apt-get -yq autoremove && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
        echo "3 * * * * freerad /usr/bin/uniq /tmp/mailgun.queue | /bin/bash && > /tmp/mailgun.queue &> /dev/null" >> /etc/crontab

# copy freeradius config file 
#COPY config_data.pm /etc/freeradius/version.3/mods-config/perl/config_data.pm

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD /etc/init.d/supervisor start
