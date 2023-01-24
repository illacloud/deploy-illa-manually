# ------------------
# build illa-builder
FROM node:18-bullseye as builder-for-frontend

## clone frontend
WORKDIR /opt/illa/illa-builder
RUN cd /opt/illa/illa-builder
RUN pwd

RUN git clone https://github.com/illa-family/illa-builder.git /opt/illa/illa-builder/
RUN git submodule init; \
    git submodule update;

RUN npm install -g pnpm
RUN whereis pnpm
RUN whereis node

## check yarn config
RUN yarn config list

## build 
RUN pnpm install
RUN pnpm build-self

# ---------------------
# build builder-backend
FROM golang:1.19-bullseye as builder-for-backend

## set env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

## build
WORKDIR /opt/illa/builder-backend
RUN cd  /opt/illa/builder-backend
RUN ls -alh

RUN git clone https://github.com/illa-family/builder-backend.git ./

RUN cat ./Makefile

RUN make all 

RUN ls -alh ./bin/illa-backend 
RUN ls -alh ./bin/illa-backend-ws 


# -------------------
# build runner images
FROM postgres:14.5-bullseye as runner


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


## copy backend bin
COPY --from=builder-for-backend /opt/illa/builder-backend /opt/illa/builder-backend


## copy frontend
COPY nginx.conf /etc/nginx/nginx.conf
COPY illa-builder.conf /etc/nginx/conf.d/app.conf
COPY --from=builder-for-frontend /opt/illa/illa-builder/apps/builder/dist/index.html /opt/illa/illa-builder/index.html
COPY --from=builder-for-frontend /opt/illa/illa-builder/apps/builder/dist/assets /opt/illa/illa-builder/assets
RUN rm /etc/nginx/conf.d/default.conf

# test nginx
RUN nginx -t

## set illa user 
RUN set -eux; \
	groupadd -r illa --gid=2022; \
	useradd -r -g illa --uid=2022 --home-dir=/opt/illa/ --shell=/bin/bash illa; \
	chown -R illa:illa /opt/illa/

RUN ls -alh /opt/illa/illa-builder/
RUN ls -alh /opt/illa/builder-backend/

## init database 
RUN mkdir -p /opt/illa/database/
RUN ln -s /var/lib/postgresql /opt/illa/database/
COPY postgres-entrypoint.sh  /opt/illa/database/
COPY postgres-init.sh /opt/illa/database
RUN chmod +x /opt/illa/database/postgres-entrypoint.sh  
RUN chmod +x /opt/illa/database/postgres-init.sh 

## add main scripts
COPY main.sh /opt/illa/
COPY config-init.sh /opt/illa/
RUN chmod +x /opt/illa/main.sh 
RUN chmod +x /opt/illa/config-init.sh 


# run
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
EXPOSE 80 8000 9999 5432
CMD ["/opt/illa/main.sh"]
