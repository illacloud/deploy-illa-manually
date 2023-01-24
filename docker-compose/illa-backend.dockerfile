# ---------------------
# build illa-backend
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
FROM alpine:latest as runner

WORKDIR /opt/illa/builder-backend/bin/

## copy backend bin
COPY --from=builder-for-backend /opt/illa/builder-backend/bin/illa-backend /opt/illa/builder-backend/bin/


RUN ls -alh /opt/illa/builder-backend/bin/



# run
EXPOSE 9999
CMD ["/bin/sh", "-c", "/opt/illa/builder-backend/bin/illa-backend"]
