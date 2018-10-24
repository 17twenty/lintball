#!/usr/bin/env bash
# shellcheck disable=SC2039
# Ignore posix non-compliance due to required use of here document
set -euo pipefail



# Ensure we run the script from the app directory, not the mounted directory
cwd=$(dirname "${0}")
cd "${cwd}"

source lib/dependencies.sh
ensure_dependencies_are_installed

# Work out if it's CFN or YAML
do_yaml_lint()
{
  yamlfile=$1
  if ! head "${yamlfile}" | grep "AWSTemplateFormatVersion" > /dev/null
  then
    # yaml code is not cloudformation
    echo "========="
    echo "yamllint running on ${yamlfile}"
    yamllint -c "./yamllintrc" "${yamlfile}"
  else
    # yaml code is cloudformation
    echo "========="
    echo "cfn-lint running on ${yamlfile}"


    # Adding Ignore for the following conditions:
    # - E2540: Pipeline stage name check
    # - E2541: pipeline stage action name check
    # - W1020: Warning on Sub function, we use the pattern: Fn::Sub "${AWS::StackName}-<some var>" everywhere
    # - W3002: Warning: This code may only work with `package` cli command. Team is well aware of this limitation
    #
    # Reference of cfn-lint Rules: https://github.com/awslabs/cfn-python-lint/blob/master/docs/rules.md
    cfn-lint "${yamlfile}" -i E2541 E2540 W1020 W3002

    # aws cli Validate template
    # https://docs.aws.amazon.com/cli/latest/reference/cloudformation/validate-template.html
    aws cloudformation validate-template --template-body file://"${yamlfile}"
  fi
}

usage()
{
  echo "Usage : $0 <file> "
  exit 1
}


if [ -z ${1+x} ]; then
  echo "Error - filename not passed to the script"
  usage
fi


export WORKING_DIR="/scan"
export LINTIGNORE_PATH="${WORKING_DIR}/.lintignore"
export RESULTS_DIR="${WORKING_DIR}/results"
mkdir -p "${RESULTS_DIR}"

export OUTPUT_FILE_PATH="${RESULTS_DIR}/lintresults-$(date "+%Y-%m-%d-%H:%M")"
# Create the file if it doesn't exist
touch "${OUTPUT_FILE_PATH}"

echo "LINTIGNORE_PATH=${LINTIGNORE_PATH}"
echo "WORKING_DIR=${WORKING_DIR}"
echo "RESULTS_DIR=${RESULTS_DIR}"
echo "OUTPUT_FILE_PATH=${OUTPUT_FILE_PATH}"
ls -al "${OUTPUT_FILE_PATH}"

# Declare file and lintignore file
FILE="${1}"
FILENAME="${WORKING_DIR}/${FILE}"

printf "\n\n======= LINTBALL ===========\n"
echo "TESTING ARG FILE  =${FILE}"
echo "CONTAINER FILENAME=${FILENAME}"
ls -alf ${FILENAME}
printf "\n==============================\n"

# debug
#echo "START FIND"
#find "${WORKING_DIR}" -path "${WORKING_DIR}/.git" -prune -o -ls
#echo "END FIND"

RC=0

# Does the given .lintignore file exist
if [ -f "${LINTIGNORE_PATH}" ] ; then

    echo "Found ${LINTIGNORE_PATH}"
    # Ignore if file is in lintignore
    if grep -q "${FILE}" "${LINTIGNORE_PATH}"; then
      echo "==========================="
      echo "Found match for file in: ${LINTIGNORE_PATH}"
      echo "Ignoring File: ${FILE}"
      echo "==========================="
      exit $RC
    fi
else
    echo "No ${LINTIGNORE_PATH} file found, ignoring"
fi


# Confirm file exists and not a lintresult outfile
if [ -f "${FILENAME}" ] && [[ "${FILENAME}" != *"lintresults."* ]]
then
    if echo "${FILENAME}" | grep \.sh$  > /dev/null
    then
        #LD_LIBRARY_PATH is to get around an error running shellcheck on docker environments
        echo "=========" >> "${OUTPUT_FILE_PATH}"
        echo "Shellcheck running on ${FILENAME}" >> "${OUTPUT_FILE_PATH}"
        # LD_LIBRARY_PATH=/tmp
        shellcheck "${FILENAME}" >> "${OUTPUT_FILE_PATH}" 2>&1 || RC=1
    fi

    if echo "${FILENAME}" | grep \.json$  > /dev/null
    then
        echo "=========" >> "${OUTPUT_FILE_PATH}"
        echo "jsonlint running on ${FILENAME}" >> "${OUTPUT_FILE_PATH}"
        jsonlint "${FILENAME}" >> "${OUTPUT_FILE_PATH}" 2>&1 || RC=1
    fi

    if echo "${FILENAME}" | grep -e \.py$ -e \.python$ > /dev/null
    then
        echo "=========" >> "${OUTPUT_FILE_PATH}"
        echo "pylint running on ${OUTPUT_FILE_PATH}" >> "${OUTPUT_FILE_PATH}"

        # Disable rule: E0401: Unable to import '<module>' (import-error)
        # Reason:
        #  - Lambdas are packaged in a separate process and uploaded to S3
        #  - If we have this rule, we will have to run pip install on all lambdas, which is out of scope for this Script.
        #
        pylint "${FILENAME}" --disable E0401 >> "${OUTPUT_FILE_PATH}" 2>&1 || RC=1
    fi


    if echo "${FILENAME}" | grep -e \.yml$ -e \.yaml$ -e \.cfn$ -e \.template$ > /dev/null
    then
            do_yaml_lint "${FILENAME}" >> "${OUTPUT_FILE_PATH}" || RC=1
    fi
fi
# Display output for capture on the terminal
cat "${OUTPUT_FILE_PATH}"

if [ "$RC" -eq 1 ]
then
    echo Linting tests result : FAIL
else
    echo Linting tests result : PASS
fi
exit $RC