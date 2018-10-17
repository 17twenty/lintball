#!/usr/bin/env bash
# shellcheck disable=SC2039
# Ignore posix non-compliance due to required use of here document
set -e

# Work out if it's CFN or YAML
do_yaml_lint()
{
  yamlfile=$1
  if ! head "${yamlfile}" | grep "AWSTemplateFormatVersion" > /dev/null
  then
    # yaml code is not cloudformation
    echo "========="
    echo "yamllint running on ${yamlfile}"
    yamllint -c /yamllintrc "${yamlfile}"
  else
    # yaml code is cloudformation
    echo "========="
    echo "cfn-lint running on ${yamlfile}"


    # Adding Ignore for the following conditions:
    # - E2541: pipeline stage action name check
    # - E3002: Making sure that resources properties are properly configured
    # - W1020: Warning on Sub function, we use the pattern: Fn::Sub "${AWS::StackName}-<some var>" everywhere
    # - W3002: Warning: This code may only work with `package` cli command. Team is well aware of this limitation
    #
    # Reference of cfn-lint Rules: https://github.com/awslabs/cfn-python-lint/blob/master/docs/rules.md
    cfn-lint "${yamlfile}" -i E2541 E2540 W1020 W3002
  fi
}

usage()
{
  echo "Usage : $0 <file>"
  exit 1
}

if [ -z ${1+x} ]; then
  echo "Error - filename not passed to the script"
  usage
fi

if ! [ -x "$(command -v shellcheck)" ]; then
  echo 'Error: shellcheck not found' >&2
  exit 1
fi

if ! [ -x "$(command -v pylint)" ]; then
  echo 'Error: pylint not found' >&2
  exit 1
fi

if ! [ -x "$(command -v cfn-lint)" ]; then
  echo 'Error: cfn-lint not found' >&2
  exit 1
fi

if ! [ -x "$(command -v yamllint)" ]; then
  echo 'Error: yamllint not found' >&2
  exit 1
fi


# Assign "unique" filename to the results using timestamp
OUTFILE="/scan/lintresults.$(date +%s%N)"
# Ensure outfile is empty just in case it pre-exists
true > "${OUTFILE}"

FILENAME=/scan/$1

# Set an exit code
RC=0
# Confirm file exists
if [ -f "${FILENAME}" ]
then
    if echo "${FILENAME}" | grep \.sh$  > /dev/null
    then
        #LD_LIBRARY_PATH is to get around an error running shellcheck on docker environments
        echo "=========" >> "${OUTFILE}"
        echo "Shellcheck running on ${FILENAME}" >> "${OUTFILE}"
        # LD_LIBRARY_PATH=/tmp
        shellcheck "${FILENAME}" >> "${OUTFILE}" 2>&1 || RC=1
    fi

    if echo "${FILENAME}" | grep -e \.py$ -e \.python$ > /dev/null
    then
        echo "=========" >> "${OUTFILE}"
        echo "pylint running on ${OUTFILE}" >> "${OUTFILE}"

        # Disable rule: E0401: Unable to import '<module>' (import-error)
        # Reason:
        #  - Lambdas are packaged in a separate process and uploaded to S3
        #  - If we have this rule, we will have to run pip install on all lambdas, which is out of scope for this Script.
        #
        pylint "${FILENAME}" --disable E0401 >> "${OUTFILE}" 2>&1 || RC=1
    fi


    if echo "${FILENAME}" | grep -e \.yml$ -e \.yaml$ -e \.cfn$ -e \.template$ > /dev/null
    then
            do_yaml_lint "${FILENAME}" >> "${OUTFILE}" || RC=1
    fi
fi
# Display output for capture on the terminal
cat "${OUTFILE}"
if [ "$RC" -eq 1 ]
then
    echo Linting tests result : FAIL
else
    echo Linting tests result : PASS
fi
exit $RC