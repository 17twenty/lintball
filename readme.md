# Lintball

## Getting Started

In the interest of getting going fast - this wraps a number of linters together
and even discerns between pure YAML and Cloudformation files.

```bash
docker run -v "$PWD:/scan" lintball:latest lintball.sh
```

The output is dumped in a `lintresults.XXXX` where X is the timestamp (you
can't use the PID as it's always 1 in docker).