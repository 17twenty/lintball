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

```bash
docker run \
  -v "$PWD:/scan" \
  lintball:latest <your-file-to-lint>
```


## Ignoring files
To optionally exclude files from the `linting` process, provide a `.lintignore` file in the working directory.
In the `.lintignore` file, add the relative path of the file.

```bash
./relative-path/to/the/ignored/file/x.sh
./relative-path/to/the/ignored/file/y.yml
./relative-path/to/the/ignored/file/z.yaml
./relative-path/to/the/ignored/file/z.template
```

## Lint Results
The output is dumped in a `lintresults.XXXX` where X is the timestamp (you
can't use the PID as it's always 1 in docker).

If you don't want to accidentally commit your lint results, add `lintresults*` to your `.gitignore` file


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