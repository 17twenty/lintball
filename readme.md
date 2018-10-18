# Lintball

## Getting Started

In the interest of getting going fast - this wraps a number of linters together
and even discerns between pure YAML and Cloudformation files.

```bash
docker run -v "$PWD:/scan" lintball:latest lintball.sh
```

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

find the diffs and run

```bash
files_to_lint=$(git diff-tree --no-commit-id --name-only -r ${CODEBUILD_SOURCE_VERSION})
for file in "${files_to_lint[@]}"; do lintball.sh "${file}"; done
```