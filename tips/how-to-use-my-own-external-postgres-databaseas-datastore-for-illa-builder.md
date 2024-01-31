How to Use My Own External Postgres Database as Datastore for Illa-Builder?
---------------------------------------------------------------------------


## Desc

This document is for the user who wants to use their own postgres database as a datastore for illa-builder.


## Database DDL 

Connect to your own postgres database and run the following SQL to create the database and table. 

The database DDLs are in this script:

[https://github.com/illacloud/build-all-in-one-image/blob/main/scripts/postgres-init.sh](https://github.com/illacloud/build-all-in-one-image/blob/main/scripts/postgres-init.sh)


## Run Image

Then config the docker run command and run it.

```bash
docker run -d \
    --name illa-builder \
    -p 80:2022 \
    -e PGHOST={your_pg_server}
    -e PGUSER={your_default_pg_user | postgres}
    -e PGPASSWORD={your_default_pg_password}
    -e ILLA_PG_ADDR={your_pg_server} \
    -e ILLA_PG_PORT=5433 \
    -e ILLA_PG_USER=illa_builder \
    -e ILLA_PG_PASSWORD=illa2022 \
    -e ILLA_PG_DATABASE=illa_builder \
    -e ILLA_SUPERVISOR_PG_ADDR={your_pg_server} \
    -e ILLA_SUPERVISOR_PG_PORT=5433 \
    -e ILLA_SUPERVISOR_PG_USER=illa_supervisor \
    -e ILLA_SUPERVISOR_PG_PASSWORD=illa2022 \
    -e ILLA_SUPERVISOR_PG_DATABASE=illa_supervisor \
    illasoft/illa-builder:latest 
```

That's it.
