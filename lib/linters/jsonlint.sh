#!/bin/bash -e

set -ou pipefail

declare COMMON_LIB_PATH=""
COMMON_LIB_PATH="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

# Disable rule: Can't follow non-constant source. Use a directive to specify location.
# dynamically generating lib path
# shellcheck disable=SC1090
source "${COMMON_LIB_PATH}"

debug "context = $(dirname $(dirname ${BASH_SOURCE[0]}))"

handle()
{
  local RC=0
  local FILENAME="${1}"

  if echo "${FILENAME}" | grep \.json$  > /dev/null
  then
    log "Invoking jsonlint on [${FILENAME}]"
    jsonlint "${FILENAME}" 2>&1 || RC=1
  fi
  exit "${RC}"
}

handle "${1}"
