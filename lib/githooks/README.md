# Overview

This folder contains scripts for pipeline quality (lint) tests. 

See https://versent.atlassian.net/wiki/spaces/TCIP/pages/585203752/Linting

## pre-commit hook

### pre-requisites
#### TODO - Move the scripts to docker to remove local dependencies
#### TODO - Strategy required for which files are in scope for linting. All files? Files changed in this commit, etc...

See [linttests.sh](./linttests.sh) and the Versent [linting](https://versent.atlassian.net/wiki/spaces/TCIP/pages/585203752/Linting#Linting-LintingonGITrepositories) page for details of:
+ Lint tools required
+ Installation instructions

### Script installation
For every repository with linting configured, you will find a pre-commit script called  

```
[ repository ]/tests/pre-commit
```

Turn the pre-commit script into a git hook by following the instructions below...

### Enable pre-commit locally
```
# Set REPO_PATH to be the full path to your repo... 
export REPO_PATH=/git/cip-config-mgmt
```

Run the following script, to:
+ Copy the pre-commit hook to a local folder
+ Ensure the commit hook script is executable
+ Remove any existing pre-commit symlink
+ symlink your pre-commit script into the .git/hooks/ repo

```bash
./create-local-pre-commit-hook.sh <path to local folder to put the pre-commit script in>
```

Or, to create manually
```bash
chmod +x ${REPO_PATH}/tests/pre-commit
rm ${REPO_PATH}/.git/hooks/pre-commit
ln -s ${REPO_PATH}/tests/pre-commit ${REPO_PATH}/.git/hooks/pre-commit

```
