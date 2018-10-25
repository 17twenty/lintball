# Lintball
Provides `linting` features, in a single execution, for the following file types:
+ yaml, yml (yamllint)
+ cfn (cfnlint) - TODO cfnnag
+ json (jsonlin)
+ .sh (shellcheck) 

Can be used as a pre-commit hook, TODO, or part of your build.

## Getting Started

1. For files that should be excluded from lintine, add a ".lintignore" file in the root of the directory. See `ignoring files` below
2. Run docker command
3. Set the "DEBUG" environment variable to true, for more logging output

```bash
docker run \
  -v "$PWD:/scan"  \
  -e DEBUG="false" \
  --rm             \
  lintball:1.0.0 <list of changed files>
  
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

## TODO

- publish to ecr