.DEFAULT_GOAL := help

# Container Metadata
MAJOR := 1
MINOR := 0
INCREMENTAL := 0
export IMAGE_NAME := lintball:$(MAJOR).$(MINOR).$(INCREMENTAL)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export COMMIT_ID := 471240192401720

# Passing Creds as environment variables
# export AWS_ACCESS_KEY_ID := $(shell aws configure --profile ${PROFILE} get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY := $(shell aws configure --profile ${PROFILE} get aws_secret_access_key)
# export AWS_SESSION_TOKEN := $(shell aws configure --profile ${PROFILE} get aws_session_token)
# export AWS_REGION := ap-southeast-2
CURRENT_WORKING_DIRECTORY = $(shell pwd)


run-dir: ## Run lintball against a directory
	docker run

.PHONY: build
build: ## Docker Compose build Lintball
	docker-compose build


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)