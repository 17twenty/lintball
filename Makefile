.DEFAULT_GOAL := help
.PHONY: publish tests test local-bash build clean dump help

# Docker Image BUILD Metadata
VERSION := $(shell cat ./lintball_version)
export IMAGE_NAME := lintball:$(VERSION)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export COMMIT_ID := $(git rev-parse --verify HEAD)


CWD = $(shell pwd)
PROFILE ?= dev
REGION ?= ap-southeast-2
ACCOUNT = $(shell aws sts get-caller-identity --output text --query "Account")
BUILD_ENV ?= devci
ECR_REPO="lintball"
ECR_TAG = $(VERSION)


publish: ## Publish to ecr
	# eval $(aws ecr get-login --no-include-email --region "${REGION}")
	remote_docker_reference="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:${ECR_TAG}"


tests: ## Run lints against all files within test/test_files
	@echo $(VERSION)
	$(MAKE) test FILE="$(shell ls test/test_files)"


test: ## Run Lint against 1 file eg: make test FILE=test.yaml LINTFILE=.lintignore
	docker run \
	--rm \
	-e AWS_ACCESS_KEY_ID=$(shell aws configure --profile ${PROFILE} get aws_access_key_id) \
	-e AWS_SECRET_ACCESS_KEY=$(shell aws configure --profile ${PROFILE} get aws_secret_access_key) \
	-e AWS_SESSION_TOKEN=$(shell aws configure --profile ${PROFILE} get aws_session_token) \
	-e AWS_DEFAULT_REGION=$(REGION) \
	-e DEBUG="true" \
	-v "$(CWD)/test/test_files:/scan" \
	$(IMAGE_NAME) $(FILE)


local-bash: ## Launch container with entrypoint: bash
	docker run --rm --entrypoint bash -v "$(CWD)/test:/scan" -it $(IMAGE_NAME)


build: clean ## Docker Compose build Lintball
	docker-compose build


clean: ## Clean up
	rm -f lintresults.*


dump:
	@echo "IMAGE_NAME - $(IMAGE_NAME)"
	@echo "BUILD_DATE - $(BUILD_DATE)"
	@echo "COMMIT_ID - $(COMMIT_ID)"

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)