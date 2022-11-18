# ------------------
# build illa-fontend
FROM node:18-bullseye as builder-for-frontend

## clone frontend
WORKDIR /opt/illa/illa-frontend
RUN cd /opt/illa/illa-frontend
RUN pwd

RUN git clone https://github.com/illa-family/illa-builder.git /opt/illa/illa-frontend/
RUN git submodule init; \
    git submodule update;

RUN whereis yarn
RUN whereis node

## build 

RUN yarn install
RUN yarn build-cloud


# -------------------
# build runner images
FROM nginx:stable-alpine as runner
RUN ls -alh /etc/nginx/

RUN apk add --no-cache \
    bash \
    sed 


## copy frontend
COPY nginx.conf /etc/nginx/nginx.conf
COPY illa-frontend.conf /etc/nginx/conf.d/illa-frontend.conf
COPY --from=builder-for-frontend /opt/illa/illa-frontend/apps/builder/dist/index.html /opt/illa/illa-frontend/index.html
COPY --from=builder-for-frontend /opt/illa/illa-frontend/apps/builder/dist/assets /opt/illa/illa-frontend/assets
RUN rm /etc/nginx/conf.d/default.conf

# test nginx
RUN nginx -t



RUN ls -alh /opt/illa/illa-frontend/

## add main scripts
COPY illa-frontend-config-init.sh /opt/illa/
COPY illa-frontend-main.sh /opt/illa/
RUN chmod +x /opt/illa/illa-frontend-main.sh 
RUN chmod +x /opt/illa/illa-frontend-config-init.sh

# HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://127.0.0.1:80/status?src=docker_health_check -H"Host:localhost" || exit 1

# run
EXPOSE 80
CMD ["/opt/illa/illa-frontend-main.sh"]
