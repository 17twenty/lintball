#!/bin/bash -e

set -ou pipefail

ensure_dependencies_are_installed()
{
  local RC=0
  for dep in shellcheck pylint cfn-lint jsonlint yamllint
  do
    if ! command -v "${dep}" > /dev/null 2>&1
    then
      echo "Error: dependency ${dep} not found" >&2
      RC=1
    fi
  done

  if [ ${RC} -eq 1 ]
  then
    exit 1
  fi
}

export -f ensure_dependencies_are_installed
