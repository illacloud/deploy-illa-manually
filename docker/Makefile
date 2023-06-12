.PHONY: all build-local init-local run-local clean

all: build-local init-local run-local

build-local:
	docker build ./ -f ./Dockerfile -t illa-builder:local

init-local:
	mkdir -p ~/illa/database; mkdir -p ~/illa/drive;

run-local:
	docker run -d -p 80:2022 --name illa_builder_local -v ~/illa/database:/opt/illa/database -v ~/illa/drive:/opt/illa/drive illasoft/illa-builder:local

rm-local:
	docker stop illa_builder_local; docker rm illa_builder_local;

 	
