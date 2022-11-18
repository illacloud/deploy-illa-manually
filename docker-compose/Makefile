.PHONY: all run-compose-with-official-images build-docker-image run-compose stop-and-remove-container clean-postgres-database-file

all: build-docker-image run-compose

run-compose-with-official-images:
	/bin/bash scripts/run-compose-with-official-images.sh

build-docker-image:
	/bin/bash scripts/build.sh

run-compose:
	/bin/bash scripts/run-compose.sh

stop-and-remove-container:
	/bin/bash scripts/stop-and-remove-container.sh

clean-postgres-database-file:
	/bin/bash scripts/clean-postgres-database-file.sh
