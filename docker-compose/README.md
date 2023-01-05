Deploy Docker Image by Docker Compose
-------------------------------------


# Desc

Build illa utils slim image and run it by docker compose on your machine.  
You can check out the scripts file which in [scripts](./scripts/) folder for more details.

Note:

We highly recommended deploying with our auto-deploy tools [illa-cli](https://github.com/illacloud/illa).

And for the moment we do not support Apple Silicon M1 (darwin-arm64 arch).



# Index

- [Desc](#desc)
- [Index](#index)
- [Config the Server Address](#config-the-server-address)
- [Run Official Slim Image](#run-official-slim-image)
- [Build Slim Image Manually and Run](#build-slim-image-manually-and-run)
- [Stop and Remove Container](#stop-and-remove-container)
- [Clean Postgres Database File](#clean-postgres-database-file)
- [Config Runtime Environment Variables](#config-runtime-environment-variables)

# Config the Server Address

If you deploy illa on a server or virtual machine (non-localhost environment), please replace the following config in ```docker-compose.yml``` and ```docker-compose-with-official-images.yml```.

```sh
# builder-backend api server serve address
API_SERVER_ADDRESS=your_server_ip_address

# builder-backend websocket server serve address
WEBSOCKET_SERVER_ADDRESS=your_server_ip_address

```

# Run Official Slim Image

Config server address in [docker-compose-with-official-images.yml](docker-compose-with-official-images.yml).  Replace localhost with your server address.

Install GNU make and type: 

```sh
make run-compose-with-official-images
```

or just execute:

```sh
/bin/bash scripts/run-compose-with-official-images.sh
```

this command will pull illasoft official slim image and run it on your docker environment.

And Login with default username **```root```**, email **```root@test.com```** and password **```password```**.

# Build Slim Image Manually and Run

Config server address in [docker-compose.yml](docker-compose.yml).  Replace localhost with your server address.

Install GNU make (or execute shell scripts in the scripts folder manually). 

For build illa all-in-one image and run, type:

```sh
make all
```

# Stop and Remove Container


```sh
make stop-and-remove-container
```


# Clean Postgres Database File

*** THIS COMMAND WILL DELETE DATABSE FILE ON YOUR DISK!!! ***  
*** BACKUP, AND DO IT CAREFULLY ***  

In Default, the postgres database will storage in ```/var/lib/illa/database/postgresql/``` folder.

Run follow command for delete it.

```sh
make clean-postgres-database-file
```


# Config Runtime Environment Variables

Edit ```scripts/run-compose.sh``` and ```scripts/run-compose.sh```  when necessary:

```sh
# repo home dir
ILLA_HOME_DIR=/var/lib/illa

# postgres database file storage folder
PG_VOLUMN=${ILLA_HOME_DIR}/database/postgresql

```

Edit ```docker-compose-with-official-images.yml``` and ```docker-compose.yml```  when necessary:

```sh
# builder-backend api server serve address
API_SERVER_ADDRESS=localhost

# builder-backend websocket server serve address
WEBSOCKET_SERVER_ADDRESS=localhost

# builder-backend websocket server serve port
WEBSOCKER_PORT=8000

# postgres database config
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

```
