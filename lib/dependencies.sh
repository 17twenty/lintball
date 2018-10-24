#!/bin/bash -e

set -ou pipefail

ensure_dependencies_are_installed()
{
    for dep in shellcheck pylint cfn-lint jsonlint yamllint
    do
        #echo "checking for dependency ${dep}"
        if ! [ -x "$(command -v ${dep})" ]; then
          echo "Error: dependency ${dep} not found" >&2
          exit 1
        fi
    done
}

export -f ensure_dependencies_are_installed