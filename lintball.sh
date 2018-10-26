#!/usr/bin/env bash
# shellcheck disable=SC2039
# Ignore posix non-compliance due to required use of here document
set -euo pipefail

declare RESULT_PREFIX="Lintball result :"
declare LINTIGNORE_FILENAME=".lintignore"

# Ensure we run the script from the app directory, not the mounted directory
cwd=$(dirname "${0}")
cd "${cwd}"

source lib/common.sh
source lib/dependencies.sh
ensure_dependencies_are_installed


usage()
{
  echo "Usage : $0 <file> "
  exit 1
}


if [ -z ${1+x} ]; then
  echo "Error - filename not passed to the script"
  usage
fi

declare WORKING_DIR="/scan"
declare LINTIGNORE_PATH="${WORKING_DIR}/${LINTIGNORE_FILENAME}"
echo "DEBUG = ${DEBUG}"
#export DEBUG="false"
debug "WORKING_DIR=${WORKING_DIR}"
debug "LINTIGNORE_PATH=${LINTIGNORE_PATH}"

RC=0

declare INPUT_FILES=${@}
declare PROCESS_FILE_FLAG=""

while read -r FILE
do
  PROCESS_FILE_FLAG="false"
  FILENAME="${WORKING_DIR}/${FILE}"


  if [ -f "${FILENAME}" ]
  then
    debug "$(ls -alF ${FILENAME})"
  fi

  # Does the given .lintignore file exist
  if [ -f "${LINTIGNORE_PATH}" ] ; then

    debug "Found ${LINTIGNORE_FILENAME} file"
    # Ignore if file is in lintignore
    if grep -q "${FILE}" "${LINTIGNORE_PATH}"; then
      log "${SEP}"
      log "Found match for file in: ${LINTIGNORE_PATH}"
      log "${RESULT_PREFIX} IGNORE"
      log "${SEP}"
    else
      PROCESS_FILE_FLAG="true"
    fi
  else
    log "No ${LINTIGNORE_PATH} file found, ignoring"
    PROCESS_FILE_FLAG="true"
  fi

  if [[ "${PROCESS_FILE_FLAG}" == "true" ]]; then
    debug "PROCESS FILE - [${FILENAME}]"

    echo ""
    log "======= LINTBALL ${FILE} ==========="
    debug "TESTING ARG FILE   =${FILE}"
    debug "CONTAINER FILENAME =${FILENAME}"

    if [ -f "${FILENAME}" ]
    then
      for linter in ./lib/linters/*.sh
      do
        debug "Testing [${FILENAME}] against Linter [$(basename ${linter})]"
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

done <<< "${INPUT_FILES}"


# Display output for capture on the terminal
printf "\n${SEP}\n"
if [ "$RC" -eq 1 ]
then
    # Echo to stderr (in subshell, to prevent issues with current shell)
    (>&2 log "${RESULT_PREFIX} FAIL")
else
    echo ""
    log "${RESULT_PREFIX} PASS"
fi
printf "${SEP}\n\n"

exit ${RC}