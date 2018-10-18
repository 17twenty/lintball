.DEFAULT_GOAL := help

# Docker Image Metadata
MAJOR := 1
MINOR := 0
INCREMENTAL := 0
export IMAGE_NAME := lintball:$(MAJOR).$(MINOR).$(INCREMENTAL)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export COMMIT_ID := 471240192401720



CWD = $(shell pwd)
PROFILE ?= dev

.PHONY: tests
tests: ## Run lints against test/test_files
	@for file in `ls test/test_files`; do \
		echo "$$file"; \
		$(MAKE) test FILE=test_files/$$file; \
	done

.PHONY: test
test: ## Run Lint against 1 file eg: make test FILE=test.yaml
	docker run \
	--rm \
	-e AWS_ACCESS_KEY_ID=$(shell aws configure --profile ${PROFILE} get aws_access_key_id) \
	-e AWS_SECRET_ACCESS_KEY=$(shell aws configure --profile ${PROFILE} get aws_secret_access_key) \
	-e AWS_SESSION_TOKEN=$(shell aws configure --profile ${PROFILE} get aws_session_token) \
	-e AWS_DEFAULT_REGION=ap-southeast-2 \
	-v "$(CWD)/test:/scan" \
	$(IMAGE_NAME) $(FILE)

.PHONY: local-bash
local-bash: ## Debug container
	docker run --rm --entrypoint bash -v "$(CWD)/test:/scan" -it $(IMAGE_NAME)

.PHONY: build
build: clean ## Docker Compose build Lintball
	docker-compose build

.PHONY: clean
clean: ## clean up before running
	rm -f lintresults.*


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)