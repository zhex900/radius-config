FROM ubuntu:trusty
MAINTAINER Jake He "zhex900@gmail.com"

EXPOSE 1812/udp
EXPOSE 1813/udp

#install dependencies
RUN apt-get update && \
        apt-get -yq install libyubikey0 libtalloc2 diffstat curl git vim libperl5.18 dpkg-dev libssl-dev ssl-cert libnumber-bytes-human-perl libdbi-perl libdbd-mysql-perl libdatetime-perl && apt-get -y build-dep freeradius && \
        git clone https://zhex900@bitbucket.org/zhex900/freeradius3.0.8.git /tmp/freeradius && \
        cd /tmp/freeradius && \
        dpkg -i ./*.deb && \
        git clone https://github.com/zhex900/radius-config.git /tmp/config_freeradius && \
        cp -r /tmp/config_freeradius/version.3/* /etc/freeradius && \
        apt-get -yq autoremove && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# copy freeradius config file 
COPY config_data.pm /etc/freeradius/mods-config/perl/config_data.pm
COPY ca.cnf /etc/freeradius/certs/ca.cnf
COPY client.cnf /etc/freeradius/certs/client.cnf
COPY server.cnf /etc/freeradius/certs/server.cnf

RUN cd /etc/freeradius/certs/ && rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt* && ./bootstrap && chown -R freerad:freerad /etc/freeradius && chown -R freerad:freerad /var/log/freeradius && echo "Australia/Perth" > /etc/timezone && mkdir /tmp/log && mkdir /tmp/log/freeradius && chown -R freerad:freerad /tmp/log/freeradius && chown -R nobody:nogroup /tmp/log/freeradius && chmod +x /etc/freeradius/mods-config/perl/send.sh

#ENTRYPOINT ["/init"]
