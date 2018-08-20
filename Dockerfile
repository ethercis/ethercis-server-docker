FROM postgres:10.4-alpine

RUN mkdir -p /var/lib/postgresql/pgdata
ENV PGDATA  /var/lib/postgresql/pgdata

#ETHERCIS: add files
ADD customise.sh /
RUN chmod +x /customise.sh

RUN  sh  -c " /usr/local/bin/docker-entrypoint.sh postgres & "  && sleep 20 &&  /customise.sh
