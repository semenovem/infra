
DOCKER_IMG_BASE := "centos:centos8"
DOCKER_IMG := "env/dev/openvpn:1"

# -----------------
# commands
# -----------------

.PHONY: help
help: Makefile
	@echo "Choose a command in:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'


## dev - start docker container
.PHONY: dev
dev:
	@docker run --rm -it \
		-w /app \
		-v $(PWD):/app:rw \
		"$(DOCKER_IMG_BASE)" bash

