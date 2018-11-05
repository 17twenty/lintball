#!/usr/bin/env bash
# shellcheck disable=SC2039
# Ignore posix non-compliance due to required use of here document
set -euo pipefail

usage()
{
  echo "Usage : $0 <file(s)> "
  exit "${1:-0}"
}

declare RESULT_PREFIX="Lintball result :"
declare LINTIGNORE_FILENAME=".lintignore"

# Ensure we run the script from the app directory, not the mounted directory
cwd=$(dirname "${0}")
cd "${cwd}"

#shellcheck disable=SC1091
source lib/common.sh

#shellcheck disable=SC1091
source lib/dependencies.sh
ensure_dependencies_are_installed

declare FILENAMES="${1:-}"
declare WORKING_DIR="/scan"
declare INPUT_FILES=("$@")

# If the user passes in a git address, clone the repo and lint the changed files
# (else, the filenames are expected as args)
if [ -n "${GIT_URI:-""}" ]; then
  WORKING_DIR="${WORKING_DIR}/git"
  FILENAMES="TODO"
  git clone "${GIT_URI}" "${WORKING_DIR}"

  # Checkout the branch we are interested in (in a subshell, so as not to affect PWD)
  $(cd "${WORKING_DIR}" && git checkout "${GIT_COMMIT}" -B "${GIT_BRANCH}")
  #printf  "running: git checkout \"${GIT_COMMIT}\" -B \"${GIT_BRANCH}\"\nOn workdir ${WORKING_DIR}\n"
  FILENAMES=$(cd "${WORKING_DIR}" && git diff --name-only "${GIT_BRANCH}" "$(git merge-base "${GIT_BRANCH}" master)")
  INPUT_FILES="${FILENAMES}"
fi


if [ -z ${FILENAMES+x} ]; then
  echo "Error - filename(s) not passed to the script"
  usage 1
fi

declare LINTIGNORE_PATH="${WORKING_DIR}/${LINTIGNORE_FILENAME}"
echo "DEBUG = ${DEBUG}"
#export DEBUG="false"
debug "WORKING_DIR=${WORKING_DIR}"
debug "LINTIGNORE_PATH=${LINTIGNORE_PATH}"
debug "${WORKING_DIR} files: $(ls -alF ${WORKING_DIR})"

RC=0

declare PROCESS_FILE_FLAG=""

for FILE in "${INPUT_FILES[@]}"
do
  PROCESS_FILE_FLAG="false"
  FILENAME="${WORKING_DIR}/${FILE}"


  if [ -f "${FILENAME}" ]
  then
    debug "$(ls -alF "${FILENAME}")"
  fi

  # Does the given .lintignore file exist
  if [ -f "${LINTIGNORE_PATH}" ] ; then

    debug "Found ${LINTIGNORE_FILENAME} file"
    # Ignore if file is in lintignore
    if grep -q "${FILE}" "${LINTIGNORE_PATH}"; then
      log "${SEP}"
      log "Found match for ${FILENAME} in: ${LINTIGNORE_PATH}"
      log "${RESULT_PREFIX} IGNORE"
      log "${SEP}"
    else
      PROCESS_FILE_FLAG="true"
    fi
  else
    log "No ${LINTIGNORE_PATH} file found, ${FILENAME} WILL be linted..."
    PROCESS_FILE_FLAG="true"
  fi

  if [[ "${PROCESS_FILE_FLAG}" == "true" ]]; then

    echo ""
    log "======= LINTBALL ${FILE} ==========="
    debug "TESTING ARG FILE   =${FILE}"
    debug "CONTAINER FILENAME =${FILENAME}"

    if [ -f "${FILENAME}" ]
    then
      for linter in ./lib/linters/*.sh
      do
        debug "Testing [\"${FILENAME}\"] against Linter [$(basename "${linter}")]"
        set +e
        ${linter} "${FILENAME}" || RC=$?
        set -e
      done
    else
      log "DELETED FILE ${FILENAME} - IGNORING"
    fi

  else
    log "Not linting file ${FILENAME}"
  fi
done


# Display output for capture on the terminal
printf "\\n%s\\n" "${SEP}"
if [ "$RC" -eq 1 ]
then
    # Echo to stderr (in subshell, to prevent issues with current shell)
    (>&2 log "${RESULT_PREFIX} FAIL")
else
    echo ""
    log "${RESULT_PREFIX} PASS"
fi
printf "%s\\n\\n" "${SEP}"

exit ${RC}