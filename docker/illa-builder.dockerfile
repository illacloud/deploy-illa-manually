# Description
# 

# postgres data at: /opt/illa/database/
# minio data at:    /opt/illa/drive/

# 
# build illa-builder-frontend
#

FROM node:18-bullseye as illa-builder-frontend

## clone frontend
WORKDIR /opt/illa/illa-builder-frontend
RUN cd /opt/illa/illa-builder-frontend
RUN pwd

RUN git clone -b develop https://github.com/illacloud/illa-builder.git /opt/illa/illa-builder-frontend/
RUN git submodule init; \
    git submodule update;

RUN npm install -g pnpm
RUN whereis pnpm
RUN whereis node

## build 

RUN pnpm install
RUN pnpm build-self



# 
# build illa-builder-backend & illa-builder-backend-ws
#

FROM golang:1.19-bullseye as illa-builder-backend

## set env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

## build
WORKDIR /opt/illa/illa-builder-backend
RUN cd  /opt/illa/illa-builder-backend
RUN ls -alh

RUN git clone -b develop https://github.com/illacloud/builder-backend.git ./

RUN cat ./Makefile

RUN make all 

RUN ls -alh ./bin/* 



#
# build illa-supervisor-backend & illa-supervisor-backend-internal
#

FROM golang:1.19-bullseye as illa-supervisor-backend

## set env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

## build
WORKDIR /opt/illa/illa-supervisor-backend
RUN cd  /opt/illa/illa-supervisor-backend
RUN ls -alh

RUN git clone -b develop https://github.com/illacloud/illa-supervisor-backend.git ./

RUN cat ./Makefile

RUN make all 

RUN ls -alh ./bin/illa-supervisor-backend
RUN ls -alh ./bin/illa-supervisor-backend-internal



#
# build minio
#
FROM minio/minio:edge as drive-minio

RUN ls -alh /opt/bin/minio


#
# build envoy
#
FROM envoyproxy/envoy:v1.18.2 as ingress-envoy

RUN ls -alh /etc/envoy

RUN ls -alh /usr/local/bin/envoy* 
RUN ls -alh /usr/local/bin/su-exec 
RUN ls -alh /etc/envoy/envoy.yaml
RUN ls -alh  /docker-entrypoint.sh 


# 
# build runner images
#

FROM postgres:14.5-bullseye as runner

#
# init
# 
RUN mkdir /opt/illa

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    netbase \
    wget \
    dumb-init \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    if ! command -v gpg > /dev/null; then \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    gnupg \
    dirmngr \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    fi

#
# set user 
#
RUN adduser --group --system envoy
RUN adduser --group --system minio
RUN set -eux; \
    groupadd -r illa --gid=2022; \
    useradd -r -g illa --uid=2022 --home-dir=/opt/illa/ --shell=/bin/bash illa; \
    chown -R illa:illa /opt/illa/


## install web server
ENV NGINX_VERSION   1.22.0
ENV NJS_VERSION     0.7.6
ENV PKG_RELEASE     1~bullseye
ENV NGINX_GPGKEY    573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62

RUN set -x \
    # create nginx user/group first, to be consistent throughout docker variants
    && addgroup --system --gid 101 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 ca-certificates \
    ; \
    found=''; \
    for server in \
    hkp://keyserver.ubuntu.com:80 \
    pgp.mit.edu \
    ; do \
    echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
    apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
    apt-get remove --purge --auto-remove -y gnupg1 && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture)" \
    && nginxPackages=" \
    nginx=${NGINX_VERSION}-${PKG_RELEASE} \
    nginx-module-xslt=${NGINX_VERSION}-${PKG_RELEASE} \
    nginx-module-geoip=${NGINX_VERSION}-${PKG_RELEASE} \
    nginx-module-image-filter=${NGINX_VERSION}-${PKG_RELEASE} \
    nginx-module-njs=${NGINX_VERSION}+${NJS_VERSION}-${PKG_RELEASE} \
    " \
    && case "$dpkgArch" in \
    amd64|arm64) \
    # arches officialy built by upstream
    echo "deb https://nginx.org/packages/debian/ bullseye nginx" >> /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    ;; \
    *) \
    # we're on an architecture upstream doesn't officially build for
    # let's build binaries from the published source packages
    echo "deb-src https://nginx.org/packages/debian/ bullseye nginx" >> /etc/apt/sources.list.d/nginx.list \
    \
    # new directory for storing sources and .deb files
    && tempDir="$(mktemp -d)" \
    && chmod 777 "$tempDir" \
    # (777 to ensure APT's "_apt" user can access it too)
    \
    # save list of currently-installed packages so build dependencies can be cleanly removed later
    && savedAptMark="$(apt-mark showmanual)" \
    \
    # build .deb files from upstream's source packages (which are verified by apt-get)
    && apt-get update \
    && apt-get build-dep -y $nginxPackages \
    && ( \
    cd "$tempDir" \
    && DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" \
    apt-get source --compile $nginxPackages \
    ) \
    # we don't remove APT lists here because they get re-downloaded and removed later
    \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    # (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
    && apt-mark showmanual | xargs apt-mark auto > /dev/null \
    && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
    \
    # create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
    && ls -lAFh "$tempDir" \
    && ( cd "$tempDir" && dpkg-scanpackages . > Packages ) \
    && grep '^Package: ' "$tempDir/Packages" \
    && echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list \
    # work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
    #   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
    #   ...
    #   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
    && apt-get -o Acquire::GzipIndexes=false update \
    ;; \
    esac \
    \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    $nginxPackages \
    gettext-base \
    curl \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
    \
    # if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then \
    apt-get purge -y --auto-remove \
    && rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
    fi \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    # create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d

RUN ls -alh /etc/nginx/


#
# assembly final image
#

#
# copy illa-builder-backend bin
#
COPY --from=illa-builder-backend /opt/illa/illa-builder-backend /opt/illa/illa-builder-backend

#
# copy illa-supervisor-backend bin
#
COPY --from=illa-supervisor-backend /opt/illa/illa-supervisor-backend /opt/illa/illa-supervisor-backend

#
# copy illa-builder-frontend
#
COPY --from=illa-builder-frontend /opt/illa/illa-builder-frontend/apps/builder/dist/index.html /opt/illa/illa-builder-frontend/index.html
COPY --from=illa-builder-frontend /opt/illa/illa-builder-frontend/apps/builder/dist/assets /opt/illa/illa-builder-frontend/assets


#
# copy nginx
#
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/illa-builder-frontend.conf /etc/nginx/conf.d/
RUN rm /etc/nginx/conf.d/default.conf


#
# copy minio
#
RUN mkdir -p /opt/illa/drive/
RUN mkdir -p /opt/illa/minio/
RUN chown -fR minio:minio /opt/illa/minio/
RUN chown -fR minio:minio /opt/illa/drive/

COPY --from=drive-minio /opt/bin/minio /usr/local/bin/minio 

COPY scripts/minio-entrypoint.sh /opt/illa/minio
RUN chmod +x /opt/illa/minio/minio-entrypoint.sh


#
# copy envoy
#
RUN mkdir -p /opt/illa/envoy
RUN mkdir -p /etc/envoy

COPY --from=ingress-envoy  /usr/local/bin/envoy* /usr/local/bin/
COPY --from=ingress-envoy  /usr/local/bin/su-exec  /usr/local/bin/
COPY --from=ingress-envoy  /etc/envoy/envoy.yaml  /etc/envoy/

COPY config/envoy/illa-unit-ingress.yaml /opt/illa/envoy
COPY scripts/envoy-entrypoint.sh /opt/illa/envoy
RUN chmod +x /opt/illa/envoy/envoy-entrypoint.sh

RUN ls -alh /usr/local/bin/envoy* 
RUN ls -alh /usr/local/bin/su-exec 
RUN ls -alh /etc/envoy/envoy.yaml


# test config
RUN nginx -t


#
# init database 
#
RUN mkdir -p /opt/illa/database/
RUN ln -s /var/lib/postgresql /opt/illa/database/

COPY scripts/postgres-entrypoint.sh  /opt/illa/database/
COPY scripts/postgres-init.sh /opt/illa/database
RUN chmod +x /opt/illa/database/postgres-entrypoint.sh  
RUN chmod +x /opt/illa/database/postgres-init.sh 

#
# add main scripts
#
COPY scripts/main.sh /opt/illa/
COPY scripts/config-init.sh /opt/illa/
RUN chmod +x /opt/illa/main.sh 
RUN chmod +x /opt/illa/config-init.sh 

#
# run
#
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
EXPOSE 80
CMD ["/opt/illa/main.sh"]
