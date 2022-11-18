# -------------------
# build illa database
FROM postgres:14.5-bullseye 

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    gosu \
    ; \
    rm -rf /var/lib/apt/lists/*

## init database 
RUN mkdir -p /opt/illa/database/
RUN ln -s /var/lib/postgresql /opt/illa/database/
COPY postgres-init.sh /opt/illa/database
COPY postgres-entrypoint.sh /opt/illa/database
RUN chmod +x /opt/illa/database/postgres-init.sh 
RUN chmod +x /opt/illa/database/postgres-entrypoint.sh 

## add main scripts
COPY illa-database-main.sh /opt/illa/
RUN chmod +x /opt/illa/illa-database-main.sh


# HEALTHCHECK --interval=5s --timeout=3s CMD netstat -an | grep 9000 > /dev/null; if [ 0 != $? ]; then exit 1; fi;


# run
EXPOSE 5432
CMD ["/opt/illa/illa-database-main.sh"]
