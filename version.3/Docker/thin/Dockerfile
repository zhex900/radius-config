FROM zhex900/fr3:stripped
MAINTAINER Jake He "zhex900@gmail.com"

COPY s6-overlay /
RUN mkdir /var/log/ && mkdir /var/log/freeradius && chown -R freerad:freerad /var/log/freeradius && /bin/chown -R freerad:freerad /etc/freeradius && /bin/chown -R nobody:nogroup /tmp 

ENTRYPOINT ["/init"]
