# Lintball

In the interest of getting going fast - this wraps a number of linters together
and even discerns between pure YAML and Cloudformation files.

## Getting Started

1. Create a ".lintignore" file in the root of the directory
2. Run docker command

```bash
docker run -v "$PWD:/scan" lintball:latest <your-file-to-lint> .lintignore
```

## Adding to lintignore

Add the relative path of the file, to the root of the directory, in the lintignore file. Each file you wish to ignore will need to be added.

## Lint Results
The output is dumped in a `lintresults.XXXX` where X is the timestamp (you
can't use the PID as it's always 1 in docker).

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