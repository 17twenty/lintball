#!/bin/bash -e

set -euo pipefail

# Set script path, to be wherever this script executes from
# (so that we can execute from any path under the git root)
declare SCRIPT_PATH=""
SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

## Get the version file path, regardless of where the surrounding script is run from
declare VERSION_FILE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lintball_version"
export LINTBALL_VERSION=$(cat ${VERSION_FILE_PATH})

usage()
{
  printf "${1}\n"
  echo "Usage:"
  printf "   ${0} <relative path to folder to copy the pre-commit hook to>\n"
  printf "\n   e.g.  ${0} ./hooks"
  exit 1
}

# Ensure we are running in the context of a git repo?
if ! git rev-parse --show-toplevel > /dev/null 2>&1
then
    usage "ERROR: Cannot create a pre-commit hook in a non git project folder"
fi

if [ -z ${1+x} ]; then
  usage "ERROR: Provide a directory, to copy the pre-commit hook script to"
fi

declare PATH_TO_PRE_COMMIT_HOOK_FOLDER="${1}"
declare PRE_COMMIT_HOOK_SCRIPT_BASENAME="pre-commit"
declare PRE_COMMIT_HOOK_SCRIPT_PATH="${PWD}/${PATH_TO_PRE_COMMIT_HOOK_FOLDER}/${PRE_COMMIT_HOOK_SCRIPT_BASENAME}"
echo "PRE_COMMIT_HOOK_SCRIPT_PATH=${PRE_COMMIT_HOOK_SCRIPT_PATH}"

mkdir -p ${PATH_TO_PRE_COMMIT_HOOK_FOLDER}

# Transform the outgoing script with sed, so that the docker version of lintball is correct
cat "${SCRIPT_PATH}/${PRE_COMMIT_HOOK_SCRIPT_BASENAME}" \
   | sed  "s/<\[\[ LINTBALL_VERSION \]\]>/${LINTBALL_VERSION}/g" \
   > "${PRE_COMMIT_HOOK_SCRIPT_PATH}"

ls -alF "${PRE_COMMIT_HOOK_SCRIPT_PATH}"

declare BASE_PATH=""
BASE_PATH=$(git rev-parse --show-toplevel)
declare PRE_COMMIT_HOOK=${BASE_PATH}/.git/hooks/pre-commit
declare PRE_COMMIT_SCRIPT="${PRE_COMMIT_HOOK_SCRIPT_PATH}"

if [ ! -f "${PRE_COMMIT_HOOK_SCRIPT_PATH}" ]; then
    echo "ERROR: The expected pre-commit script, [${PRE_COMMIT_HOOK_SCRIPT_PATH}], does not exist or is not accessible by the current user"
    exit 1
fi

# Make executable, remove existing symlink (if symlink exists), create new symlink
chmod +x "${PRE_COMMIT_HOOK_SCRIPT_PATH}"
[ -L "${PRE_COMMIT_HOOK}" ] && echo "Removing existing link at ${PRE_COMMIT_HOOK}" && rm "${PRE_COMMIT_HOOK}"
ln -s "${PRE_COMMIT_HOOK_SCRIPT_PATH}" "${PRE_COMMIT_HOOK}" && echo "Created symlink: " && ls -lF "${PRE_COMMIT_HOOK}"
