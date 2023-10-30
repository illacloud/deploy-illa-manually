<div align="center">
  <a href="https://github.com/illacloud/deploy-illa-manually">
    <img alt="ILLA Design Logo" width="120px" height="120px" src="https://github.com/illacloud/.github/blob/main/assets/images/illa-logo.svg"/>
  </a>
</div>

<h1 align="center"><a href="https://github.com/illacloud/deploy-illa-manually">Deploy Illa Manually</a> </h1>

<p align="center">Deploy illa utils manually. Docker and k8s are all avaliable in this repo.</p>


<p align="center">
  <a href="https://discord.gg/illacloud"><img src="https://img.shields.io/badge/chat-Discord-7289DA?logo=discord" height=18></a>
  <a href="https://twitter.com/illacloudHQ"><img src="https://img.shields.io/badge/Twitter-1DA1F2?logo=twitter&logoColor=white" height=18></a>
  <a href="https://github.com/orgs/illacloud/discussions"><img src="https://img.shields.io/badge/discussions-GitHub-333333?logo=github" height=18></a>
  <a href="./LICENSE"><img src="https://img.shields.io/github/license/illacloud/illa-builder" height=18></a>
</p>




# Desc

Deploy illa utils manually. Docker and k8s are all avaliable in this repo.  

(Note: We highly recommended deploying with our auto-deploy tools [illa-cli](https://github.com/illacloud/illa))


# Index 

* [Desc](#Desc)
* [Quick Start](#quick-start)
* [Build Docker All-in-One Image](https://github.com/illacloud/build-all-in-one-image)
* [Run by Docker Compose](./docker-compose/docker-compose.md)
* [Run by Kubernetes](./kubernetes/README.md)
* [How to Build Your Own Illa Units and Run it Locallly](./build-by-yourself/README.md)
* [Known Issues](./known-issues/known-issues.md)


# Tips
* [How to Connect My Postgres Database in Resource?](#how-to-connect-my-postgres-database-in-resource.md)
* [How to Use My Own External Postgres Database as Datastore for Illa-Builder?](#how-to-use-my-own-external-postgres-databaseas-datastore-for-illa-builder.md)


# Quick Start

Just type:

```sh
mkdir -p ~/illa/database; mkdir -p ~/illa/drive; 
docker run -d -p 80:2022 --name illa_builder -v ~/illa/database:/opt/illa/database -v ~/illa/drive:/opt/illa/drive illasoft/illa-builder:latest
```

And Login with default username **```root```** and password **```password```** (self-host mode (docker all-in-one image) only).
