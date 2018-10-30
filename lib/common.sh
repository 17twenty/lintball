#!/bin/bash -e

export SEP="====================================================================="

log(){
  echo "$(date +%Y-%m-%dT%H:%M:%S%z) INFO: $(basename "${0}") [$$] ${*}"
}


debug(){
  if [[ "${DEBUG}" == "true" ]]; then
    echo "$(date +%Y-%m-%dT%H:%M:%S%z) DEBUG: $(basename "${0}") [$$] ${*}"
  fi
}


warn(){
  echo "$(date +%Y-%m-%dT%H:%M:%S%z) WARN: $(basename "${0}") [$$] ${*}" 1>&2
}


die(){
  echo "$(date +%Y-%m-%dT%H:%M:%S%z) ERROR: $(basename "${0}") [$$] ${*}, exiting ..." 1>&2
  exit 1
}

dump_env_vars()
{
  echo "GIT_HOST:           ${GIT_HOST}"
  echo "GIT_OAUTH_TOKEN:    ${GIT_OAUTH_TOKEN}"
  echo "GIT_OWNER:          ${GIT_OWNER}"
  echo "GIT_BRANCH:         ${GIT_BRANCH}"
  echo "GIT_COMMIT:         ${GIT_COMMIT}"
  echo "GIT_REPO_NAME:      ${GIT_REPO_NAME}"
}

export -f log
export -f debug
export -f warn
export -f die
export -f dump_env_vars