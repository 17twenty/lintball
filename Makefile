.DEFAULT_GOAL := help
.PHONY: publish tests test local-bash build clean dump help ecr-login

# Docker Image BUILD Metadata
export VERSION := $(shell cat ./lintball_version)
export IMAGE_NAME := lintball:$(VERSION)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export LINTBALL_COMMIT_ID := $(git rev-parse --verify HEAD)

ENV_FILE?=.env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))

CWD = $(shell pwd)
CFN_OUTPUT_DIR = output
PROFILE ?= default
REGION ?= ap-southeast-2
ACCOUNT = $(shell aws sts get-caller-identity --output text --query "Account")
BUILD_ENV ?= devci
ECR_REPO = "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/$(IMAGE_NAME)"


publish: tests ecr-login ## Publish to ecr
	docker tag $(IMAGE_NAME) $(ECR_REPO) \
	&& docker push $(ECR_REPO)

tests: ## Run lints against all files within test/test_files
	$(MAKE) test FILE="$(shell ls test/test_files)"

test: ## Run Lint against 1 file eg: make test FILE=test.yaml
	docker run \
	--rm \
	-e AWS_ACCESS_KEY_ID=$(shell aws configure --profile ${PROFILE} get aws_access_key_id) \
	-e AWS_SECRET_ACCESS_KEY=$(shell aws configure --profile ${PROFILE} get aws_secret_access_key) \
	-e AWS_SESSION_TOKEN=$(shell aws configure --profile ${PROFILE} get aws_session_token) \
	-e AWS_DEFAULT_REGION=$(REGION) \
	-e DEBUG="true" \
	-v "$(CWD)/test/test_files:/scan" \
	-i "$(IMAGE_NAME)" $(FILE)

lint-git-changes: ## Instead of passing names / shared folder to the container, pull down the changes from a git repo
	docker run \
	-e GIT_HOST=$(GIT_HOST) \
	-e GIT_OAUTH_TOKEN=$(GIT_OAUTH_TOKEN) \
	-e GIT_OWNER=$(GIT_OWNER) \
	-e GIT_REPO_NAME=$(GIT_REPO_NAME) \
	-e GIT_BRANCH=$(GIT_BRANCH) \
	-e GIT_COMMIT=$(GIT_COMMIT) \
	-e GIT_URI="https://$(GIT_OAUTH_TOKEN)@$(GIT_HOST)/$(GIT_OWNER)/$(GIT_REPO_NAME).git" \
	-e DEBUG="true" \
	--rm \
	$(IMAGE_NAME)

test-cfn: ## Run cfn-lint against cloudformation
	cfn-lint cloudformation/lintball-ecr.cfn

local-bash: ## Launch container with entrypoint: bash
	docker run \
	  --rm \
	  --entrypoint bash \
	  -v "$(CWD)/test:/scan" \
	  -it \
	  $(IMAGE_NAME)

build: clean ## Docker Compose build Lintball
	docker-compose build

clean: ## Clean up
	rm -f lintresults.*

create-ecr-repo: test-cfn ## Create Lintball's AWS ECR repo
	aws cloudformation deploy \
	  --template-file "cloudformation/lintball-ecr.cfn" \
	  --stack-name "lintball"

dump:
	@echo "IMAGE_NAME          - $(IMAGE_NAME)"
	@echo "BUILD_DATE          - $(BUILD_DATE)"
	@echo "LINTBALL_COMMIT_ID  - $(LINTBALL_COMMIT_ID)"
	@echo "GIT_HOST            - $(GIT_HOST)"
	@echo "GIT_OAUTH_TOKEN     - $(GIT_OAUTH_TOKEN)"
	@echo "GIT_OWNER           - $(GIT_OWNER)"
	@echo "GIT_BRANCH          - $(GIT_BRANCH)"
	@echo "GIT_COMMIT          - $(GIT_COMMIT)"
	@echo "GIT_REPO_NAME       - $(GIT_REPO_NAME)"

ecr-login:
	@eval $(aws ecr --profile $(PROFILE) get-login --no-include-email --region "${REGION}")

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)