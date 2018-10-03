FROM alpine:3.7

RUN apk add --update openjdk8

#need psql client to wait for db image to start
RUN apk add postgresql-client && rm -rf /var/cache/apk/*

RUN mkdir -p /etc/opt/ecis
COPY ethercis_files/etc_opt_ecis/ /etc/opt/ecis/

RUN mkdir -p /opt/ecis
COPY ethercis_files/opt_ecis/ /opt/ecis/

RUN mkdir -p /var/opt/ecis
COPY ethercis_files/var_opt_ecis/ /var/opt/ecis/

RUN mkdir -p /ethercis

COPY ethercis_files/env.rc /ethercis/env.rc

COPY ethercis_files/start_inidus_ethercis.sh /ethercis/start_inidus_ethercis.sh
RUN chmod +x /ethercis/start_inidus_ethercis.sh

COPY ethercis_files/wait-for-postgres.sh /ethercis/wait-for-postgres.sh
RUN chmod +x /ethercis/wait-for-postgres.sh

CMD ["/ethercis/wait-for-postgres.sh", "/ethercis/start_inidus_ethercis.sh"]
