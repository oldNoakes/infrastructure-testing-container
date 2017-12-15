SHELL  := /bin/bash
RED    := \033[0;31m
GREEN  := \033[0;32m
CYAN   := \033[0;36m
YELLOW := \033[1;33m
NC     := \033[0m # No Color

OWNER=oldnoakes
IMAGE_NAME=infrastest/centos
BASE_NAME=$(OWNER)/$(IMAGE_NAME)

COMMIT ?= fake
TRAVIS_BUILD_NUMBER ?= fake

GIT_TAG=$(BASE_NAME):$(COMMIT)
BUILD_TAG=$(BASE_NAME):0.1.$(TRAVIS_BUILD_NUMBER)
LATEST_TAG=$(BASE_NAME):latest

.PHONY: clean build run test bash
.DEFAULT_GOAL := usage

test-defaults:
	@echo "Var is: ${VARIABLE} it is"

usage:
	@printf "${YELLOW}make build               ${GREEN}# Build centos docker image ${NC}\n"
	@printf "${YELLOW}make test                ${GREEN}# Test centos docker image ${NC}\n"
	@printf "${YELLOW}make bash                ${GREEN}# Run the centos docker and return a bash prompt on the container${NC}\n"

clean:
	@printf "Killing the running docker container: test-docker-build \n"
	@-docker kill test-docker-build

lint:
	docker run -it --rm -v "$(PWD)/Dockerfile:/Dockerfile:ro" redcoolbeans/dockerlint

build: clean lint
	docker build -t $(GIT_TAG) --rm -f Dockerfile .
	
run: build
	docker run --name test-docker-build -d --cap-add=SYS_ADMIN --cap-add=NET_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro -e "container=docker" --rm --volume $(shell pwd)/test:/test -w "/test" $(GIT_TAG)

test: run
	docker exec test-docker-build /bin/bash -c 'sleep 10; ./test.sh 7' # need sleep before testing because sshd service may take some time to come up
	docker kill test-docker-build

tag: test
	docker tag $(GIT_TAG) $(BUILD_TAG)
	docker tag $(GIT_TAG) $(LATEST_TAG)

login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASSWORD)"

push: login
	docker push $(GIT_TAG)
	docker push $(BUILD_TAG)
	docker push $(LATEST_TAG)

bash: run
	docker exec -it test-docker-build /bin/bash

