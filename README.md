# Lintball

Provides `linting` features, in a single execution, for the following file types:

+ yaml, yml (yamllint)
+ cfn (cfnlint) - TODO cfnnag
+ json (jsonlin)
+ .sh (shellcheck)

## Lintball operation modes
The Lintball container can be used in 2 modes

+ Option 1 - Preferred - Pass the name of all changed files to Lintball. The Lintball container will execute the `Linters` against each changed file.
  + e.g. As a local pre-commit hook or a build pipeline (aws code build/jenkins/etc...), where a list of changed filenames is passed into the Lintball process)

+ Option 2 - Pass the details of the git repo / git branch / git commit / etc... to the Lintball container. Lintball will clone the repo locally, checkout the branch etc... and apply the `Linters`.
(nb: Option 2 is provided as a temporary fix to get around this [issue](https://github.com/aws/aws-codebuild-docker-images/issues/76) )
Details of using option 2 are provided at the end of this README.

## Option 1
### Getting Started

1. For files that should be excluded from linting, add a ".lintignore" file in the root of the directory. See `ignoring files` below
2. Run docker command
3. Set the "DEBUG" environment variable to true, for more logging output

```bash
docker run \
  -v "$PWD:/scan"  \
  -e DEBUG="false" \
  --rm             \
  lintball:1.0.0 <space separated list of changed files>

  # e.g.
  docker run -v $PWD:/scan -e DEBUG="false" --rm lintball:1.0.0 "${CHANGED_FILES}"
```

### Ignoring files

To optionally exclude files from the `linting` process, provide a `.lintignore` file in the working directory.
In the `.lintignore` file, add the `RELATIVE` path of the file.

```bash
./relative-path/to/the/ignored/file/x.sh
./relative-path/to/the/ignored/file/y.yml
./relative-path/to/the/ignored/file/z.yaml
./relative-path/to/the/ignored/file/z.template
```

### Lint Results

The output is dumped to std out.

### Building Lintball Docker Image

```bash
make build
```

### Running Tests

```bash
make tests
```

### Testing locally - manually

```bash
make build && ./lib/githooks/pre-commit
```

### Enabling, as a pre-commit hook

See the [README](./lib/githooks/README.md) for details on how to enable, as a pre-commit hook.

## Version Control

Lintball is currently being version controlled by the file: "lintball_version"

### Updating version

If you are:

1. Adding / Removing rules to lintball linters
2. Updating one of the linters to a newer version
3. Adding a new linter
4. Removing a linter

Please update the version file

guide: [Semantic Versioing](https://semver.org/)

### Publishing Update

1. Any changes have to be tested
2. All Changes must be PR'd
3. Only master should be published

#### Publish update to DEV for test

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
export AWS_PROFILE=dev
make publish
```

#### Publishing update to PROD

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
export AWS_PROFILE=build
make publish
```

### Creating new Lintball ECR repo

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
export AWS_PROFILE=<aws profile>
make create-ecr-repo
```

## Option 2 
Execute the lintball container, in a shell where the required git ENV vars are set
An example would be to create a .env file, with the git details below, and running `make lint-git-changes`. 
The `lint-git-changes` tasks will pass the GIT variables below to the docker container. 
(The docker container will then pull the repo from the git host and apply the Lintball `Linters`)

```bash 
GIT_OAUTH_TOKEN=dkdkdkdkdkdkdkdkdkdkdkdkdkdkdk
GIT_HOST=github.com
GIT_OWNER=superdude-x
GIT_BRANCH=feature/big-change
GIT_COMMIT=4b68emycommitide21e785d3a4
GIT_REPO_NAME=my-repo
```

