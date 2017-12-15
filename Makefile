SHELL  := /bin/bash
RED    := \033[0;31m
GREEN  := \033[0;32m
CYAN   := \033[0;36m
YELLOW := \033[1;33m
NC     := \033[0m # No Color

BASE_NAME = oldnoakes/infratest/centos

.PHONY: all build test tag_latest release

usage:
	@printf "${YELLOW}make build               ${GREEN}# Build centos docker image ${NC}\n"
	@printf "${YELLOW}make test                ${GREEN}# Test centos docker image ${NC}\n"
	@printf "${YELLOW}make release             ${GREEN}# Release centos docker image ${NC}\n"
	@printf "${YELLOW}make bash	               ${GREEN}# Run the centos docker and return a bash prompt on the continer${NC}\n"

clean:
	@printf "Killing the running docker container: test-docker-build \n"
	@-docker kill test-docker-build

all: build

build: clean
	docker build -t $(BASE_NAME) --rm -f Dockerfile .
	
run: build
	docker run --name test-docker-build -d --cap-add=SYS_ADMIN --cap-add=NET_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro -e "container=docker" --rm --volume $(shell pwd)/test:/test -w "/test" $(BASE_NAME)

test: run
	docker exec test-docker-build /bin/bash -c 'sleep 10; ./test.sh 7' # need sleep before testing because sshd service may take some time to come up
	docker kill test-docker-build

bash: run
	docker exec -it test-docker-build /bin/bash
