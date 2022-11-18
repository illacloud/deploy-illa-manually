.PHONY: all build-docker-image run run-by-podman stop-and-remove-container clean-postgres-database-file

all: build-docker-image run

run-official-image:
	/bin/bash scripts/run-official-image.sh

build-docker-image:
	/bin/bash scripts/build.sh

run:
	/bin/bash scripts/run.sh

run-by-podman:
	/bin/bash scripts/run-by-podman.sh

stop-and-remove-container:
	/bin/bash scripts/stop-and-remove-container.sh

clean-postgres-database-file:
	/bin/bash scripts/clean-postgres-database-file.sh
