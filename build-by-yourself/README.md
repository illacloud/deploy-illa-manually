How to Build Your Own Illa Units 
--------------------------------


# Index 

* [Desc](#Desc)
* [Architechture](#Architechture)
* [Build illa-builder](#build-illa-builder)
* [Build builder-backend](#build-builder-backend)
* [Build illa-supervisor-backend](#build-illa-supervisor-backend)
* [Need Support?](#need-support)


# Desc

In this tutorial, You can find the way out to build illa units by yourself, and all details about illa units.


# Architechture

Illa consists of the following parts (called by illa unit):

- [illa-builder](https://github.com/illacloud/illa-builder) (as frontend)
- [builder-backend](https://github.com/illacloud/builder-backend) (as illa builder backend API service)
- [illa-supervisor-backend](https://github.com/illacloud/illa-supervisor-backend) (for auth, account management, RBAC etc.)



# Build illa-builder

## Prepare Build Environment and Required Libs

- linux kernel 4.5 or later version, ubuntu 20.04 LTS are recommended. 
- node.js 18 or later version

## Clone From Source

```bash
mkdir /opt/illa/illa-builder-frontend
cd /opt/illa/illa-builder-frontend
git clone -b main https://github.com/illacloud/illa-builder.git /opt/illa/illa-builder-frontend/
```

## Init Git Submodule

```bash
git submodule init
git submodule update
```

## Install PNPM

```bash
npm install -g pnpm
```

## Build

```bash
pnpm install
pnpm build-self
```

The build products are in ```/opt/illa/illa-builder-frontend/apps/builder/dist/```.

- dist/index.html for entrance.
- dist/assets for frontend assets (css & javascripts).

# Build builder-backend

## Prepare Build Environment and Required Libs

- golang 1.19 or later version.

## Clone From Source

```bash
makedir /opt/illa/illa-builder-backend
cd /opt/illa/illa-builder-backend

git clone -b main https://github.com/illacloud/builder-backend.git ./
```

## Build

```bash
make all 
ls -alh ./bin/* 
```
The build products are in ```/opt/illa/illa-builder-backend/bin/```.

- bin/illa-builder-backend for WEB API.
- bin/illa-builder-backend-ws for WebSocket server.



# Build illa-supervisor-backend

## Prepare Build Environment and Required Libs

- golang 1.19 or later version.

## Clone From Source

```bash
makedir /opt/illa/illa-supervisor-backend
cd /opt/illa/illa-supervisor-backend

git clone -b main https://github.com/illacloud/illa-supervisor-backend.git ./
```

## Build

```bash
make all 
ls -alh ./bin/* 
```
The build products are in ```/opt/illa/illa-supervisor-backend/bin/```.

- bin/illa-supervisor-backend for supervisor API.
- bin/illa-supervisor-backend-internal for supervisor internal API. (**Note this API design for other backend program retrieve raw data of illa units, so do not start and listen this API on public IP address.**)


# Need Support?

- Call @Karminski at our [Discord](https://discord.com/invite/illacloud). Any questions are welcome!
