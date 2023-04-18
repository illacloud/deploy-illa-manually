deploy-illa-manually
--------------------

# Desc

Deploy illa utils manually. Docker and k8s are all avaliable in this repo.  

Note:

We highly recommended deploying with our auto-deploy tools [illa-cli](https://github.com/illacloud/illa).

And for the moment we do not support Apple Silicon M1 (darwin-arm64 arch).

# Index 

* [Desc](#Desc)
* [Quick Start](#quick-start)
* [Docker All-in-One Image](./docker/README.md)
* [Kubernetes](./kubernetes/README.md)
* [How to Build Your Own Illa Units](./build-by-yourself/README.md)
* [Known Issues](./known-issues/known-issues.md)


# Tips
* [How to Connect My Postgres Database in Resource?](#how-to-connect-my-postgres-database-in-resource.md)
* [How to Use My Own External Postgres Database as Datastore for Illa-Builder?](#how-to-use-my-own-external-postgres-databaseas-datastore-for-illa-builder.md)


# Quick Start

Just type:

```sh
docker run -d --name illa-builder -p 80:80 illasoft/illa-builder:latest 
```

And Login with default username **```root```** and password **```password```** (self-host mode (docker all-in-one image) only).
