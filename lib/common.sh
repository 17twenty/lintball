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