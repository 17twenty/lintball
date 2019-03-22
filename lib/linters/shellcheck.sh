#!/bin/bash

set -ou pipefail

declare COMMON_LIB_PATH=""
COMMON_LIB_PATH="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

# TODO - https://github.com/koalaman/shellcheck/wiki/Ignore


# Disable rule: Can't follow non-constant source. Use a directive to specify location.
# dynamically generating lib path
# shellcheck disable=SC1090
source "${COMMON_LIB_PATH}"

handle()
{
  local RC=0
  local FILENAME="${1}"

  if echo "${FILENAME}" | grep \.sh$  > /dev/null
  then
      log "Invoking shellcheck on [${1}]"
      shellcheck -x "${FILENAME}" 2>&1 || RC=1
  fi
  exit "${RC}"
}

handle "${1}"
