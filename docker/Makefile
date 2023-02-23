.PHONY: all build run run-by-podman stop-and-remove-container clean-postgres-database-file

all: build run

build:
	/bin/bash build-scripts/build.sh

run-official-image:
	/bin/bash deploy-scripts/run-official-image.sh

run:
	/bin/bash deploy-scripts/run.sh

run-by-podman:
	/bin/bash deploy-scripts/run-by-podman.sh

stop-and-remove-container:
	/bin/bash deploy-scripts/stop-and-remove-container.sh

clean-postgres-database-file:
	/bin/bash deploy-scripts/clean-postgres-database-file.sh
