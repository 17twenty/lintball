#!/bin/bash

set -ou pipefail

declare COMMON_LIB_PATH=""
COMMON_LIB_PATH="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

# Disable rule: Can't follow non-constant source. Use a directive to specify location.
# dynamically generating lib path
# shellcheck disable=SC1090
source "${COMMON_LIB_PATH}"

# TODO _ https://docs.pylint.org/en/1.6.0/faq.html#message-control

handle()
{
  local RC=0
  local FILENAME="${1}"

  if echo "${FILENAME}" | grep -e \.py$ -e \.python$ > /dev/null
  then

    debug "Invoking pylint on [${FILENAME}]"

    # Disable rule: E0401: Unable to import '<module>' (import-error)
    # Reason:
    #  - Lambdas are packaged in a separate process and uploaded to S3
    #  - If we have this rule, we will have to run pip install on all lambdas, which is out of scope for this Script.
    #
    pylint "${FILENAME}" --disable E0401 2>&1
    RC=${?}
  fi
  exit "${RC}"
}

handle "${1}"
