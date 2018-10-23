.DEFAULT_GOAL := help

# Docker Image BUILD Metadata
MAJOR := 1
MINOR := 0
INCREMENTAL := 0
export IMAGE_NAME := lintball:$(MAJOR).$(MINOR).$(INCREMENTAL)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export COMMIT_ID := $(git rev-parse --verify HEAD)


CWD = $(shell pwd)
PROFILE ?= dev
REGION ?= ap-southeast-2
ACCOUNT = $(shell aws sts get-caller-identity --output text --query "Account")
BUILD_ENV ?= devci
ECR_REPO="lintball"
ECR_TAG = $(MAJOR).$(MINOR).$(INCREMENTAL)


.PHONY: publish
publish: ## Publish to ecr
	# eval $(aws ecr get-login --no-include-email --region "${REGION}")
	remote_docker_reference="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:${ECR_TAG}"


.PHONY: tests
tests: ## Run lints against all files within test/test_files
	@for file in `ls test/test_files`; do \
		echo "Running lintball on: $$file"; \
		$(MAKE) test FILE=test_files/$$file LINTFILE=test_files/.lintignore; \
	done


.PHONY: test
test: ## Run Lint against 1 file eg: make test FILE=test.yaml LINTFILE=.lintignore
	docker run \
	--rm \
	-e AWS_ACCESS_KEY_ID=$(shell aws configure --profile ${PROFILE} get aws_access_key_id) \
	-e AWS_SECRET_ACCESS_KEY=$(shell aws configure --profile ${PROFILE} get aws_secret_access_key) \
	-e AWS_SESSION_TOKEN=$(shell aws configure --profile ${PROFILE} get aws_session_token) \
	-e AWS_DEFAULT_REGION=$(REGION) \
	-v "$(CWD)/test:/scan" \
	$(IMAGE_NAME) $(FILE) $(LINTFILE)


.PHONY: local-bash
local-bash: ## Launch container with entrypoint: bash
	docker run --rm --entrypoint bash -v "$(CWD)/test:/scan" -it $(IMAGE_NAME)


.PHONY: build
build: clean ## Docker Compose build Lintball
	docker-compose build


.PHONY: clean
clean: ## Clean up
	rm -f lintresults.*


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)