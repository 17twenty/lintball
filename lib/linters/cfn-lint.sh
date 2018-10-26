#!/bin/bash

set -ou pipefail

declare COMMON_LIB_PATH=""
COMMON_LIB_PATH="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

#shellcheck disable=SC1090
source "${COMMON_LIB_PATH}"


# TODO - https://github.com/awslabs/cfn-python-lint

handle()
{
  local RC=0
  local FILENAME="${1}"

  if echo "${FILENAME}" | grep -e \.yml$ -e \.yaml$ -e \.yaml$ -e \.cfn$ -e \.template$ > /dev/null
  then

    if head "${FILENAME}"  | grep "AWSTemplateFormatVersion" > /dev/null
    then
      log "Invoking cfn-lint on [${FILENAME}]"
      cfn-lint "${FILENAME}" -i E2541 E2540 W1020 W3002 2>&1
      RC=${?}
    fi
  fi
  exit "${RC}"
}

handle "${1}"
