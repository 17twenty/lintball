# Overview

This folder contains scripts for pipeline quality (lint) tests.

The docker container contains several linting tools that can be invoked in standalone mode, or by a git pre-commit hook.

To enable the pre-commit hook, follow the steps below, which describe how to:

+ Copy the pre-commit hook to a local folder
+ Ensure the commit hook script is executable
+ Remove any existing pre-commit symlink
+ symlink your pre-commit script into the .git/hooks/ repo
+ toggle debug logging output on the linting script

## Clone this repo locally

```bash
git clone git@github.com:Versent/lintball.git
```

## Build the lintball image

```bash
  /tmp> cd /path/to/cloned/lintball
  /path/to/cloned/lintball> make build

  # verify your lintball docker image built
  docker images | grep lintball
```

## Install the pre-commit script and hook

+ cd to the git project you would like to have linted before every commit

```bash
  /tmp> cd /my/project/to/be/linted>
  /my/project/to/be/linted>
```

+ Run the script to copy the pre commit script and symbolic link into your existing project

e.g. To create a 'hooks' folder, containing your pre-commit script...

```bash
  /my/project/to/be/linted> /path/to/cloned/lintball/lib/githooks/create-local-pre-commit-hook.sh  hooks

  #output
  Created symlink:
  lrwxr-xr-x  1 myuser  staff  58 Oct 26 11:06 /my/project/to/be/linted/.git/hooks/pre-commit@ -> /my/project/to/be/linted/hooks/pre-commit

```

nb: You may want to add the created folder, e.g. hooks, to your .gitignore file

+ Verify the githoook

```bash
ls -alF /my/project/to/be/linted/.git/hooks/pre-commit
```

## Debug output toggle

To enable debug logging, change the docker environment variable, in the [pre-commit](./pre-commit) script to "true".

### Versent internal link

See https://versent.atlassian.net/wiki/spaces/TCIP/pages/585203752/Linting
