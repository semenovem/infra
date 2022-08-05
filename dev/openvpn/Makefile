
DOCKER_IMG_BASE := "centos:centos8"
DOCKER_IMG := "self/dev/openvpn:1"

# -----------------
# commands
# -----------------

.PHONY: help
help: Makefile
	@echo "Choose a command in:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'

# TODO добавить сборку образа отдельным шагом

## dev - start docker container
.PHONY: dev
dev:
	@docker run --rm -it \
		-w /app \
		-v $(PWD):/app:rw \
		"$(DOCKER_IMG)" bash -c "./install.sh"
