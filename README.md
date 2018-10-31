# Lintball

Provides `linting` features, in a single execution, for the following file types:

+ yaml, yml (yamllint)
+ cfn (cfnlint) - TODO cfnnag
+ json (jsonlin)
+ .sh (shellcheck)

Can be used as a pre-commit hook, details below, or part of your build.

## Getting Started

1. For files that should be excluded from lintine, add a ".lintignore" file in the root of the directory. See `ignoring files` below
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

## Ignoring files

To optionally exclude files from the `linting` process, provide a `.lintignore` file in the working directory.
In the `.lintignore` file, add the `RELATIVE` path of the file.

```bash
./relative-path/to/the/ignored/file/x.sh
./relative-path/to/the/ignored/file/y.yml
./relative-path/to/the/ignored/file/z.yaml
./relative-path/to/the/ignored/file/z.template
```

## Lint Results

The output is dumped to std out.

## Building Lintball Docker Image

```bash
make build
```

## Running Tests

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

You don't need to declare a `PROFILE` parameter when publishing a test image

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
make publish
```

#### Publishing update to PROD

The `PROFILE` parameter refers to your amp2aws profile (build, dev, sit, onb, etc).

Lintball Prod images will be registered in the AWS build account.

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
make publish PROFILE=build
```

### Creating new Lintball ECR repo

Lintball will be using AWS ECR to register and pull images.

The `PROFILE` parameter refers to your amp2aws profile (build, dev, sit, onb, etc).

Lintball Prod images will be registered in the AWS build account.

```bash
# Following Command assumes you have valid AWS creds, please use amp2aws to generate valid creds
make create-ecr-repo PROFILE=<your profile>
```