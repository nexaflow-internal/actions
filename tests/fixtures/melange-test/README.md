# `melange-test` fixture

The ARC job in `.github/workflows/arc-wave1-test.yml` exercises the
`melange-test` composite action in dry-run mode against
`tests/fixtures/hello-fixture.yaml`. A dry-run prints the fully expanded
`melange test` command to the job log, writes the same line to
`$RUNNER_TEMP/melange-test-command.txt`, and exits before executing anything.
No credentials, signing key or network writes are needed.

## Local mode

Local mode tests an apk that is already present in a local repository. The
caller supplies `repository-path` and the `public-key-path` that verifies that
repository's index:

```yaml
- uses: nexaflow-internal/actions/melange-test@v6
  with:
    config: hello-fixture.yaml
    package: hello-fixture
    repository-path: ${{ runner.temp }}/apk-repo
    public-key-path: ${{ runner.temp }}/keyring/ci.rsa.pub
```

`public-key-path` defaults to `${{ runner.temp }}/keyring/ci.rsa.pub`, the
public half of the default throwaway key used by `melange-build@v6`. Pass the
`public-key-path` output of that action instead when the repository was
produced in a different job or with a custom key. The action adds
`--repository-append "$REPOSITORY_PATH"` and
`--keyring-append "$PUBLIC_KEY_PATH"` to the test command.

## Published mode

Published mode tests an apk that is already in a public index. Set
`repository-path` and `public-key-path` to empty strings and supply the
published endpoints; no local signing key is required:

```yaml
- uses: nexaflow-internal/actions/melange-test@v6
  with:
    config: hello-fixture.yaml
    package: hello-fixture
    repository-path: ''
    public-key-path: ''
    base-repository: https://dl.nexaflow.by/main
    base-keyring: https://dl.nexaflow.by/keyring/nexaflow.rsa.pub
```

This produces `--repository-append` and `--keyring-append` flags for the
published endpoints and no local-key flags. Testing a published artifact
verifies the apk recorded in that index, not a freshly produced one.

`extra-repository`, when supplied, is appended as another `--repository-append`
in either mode. `base-repository` and `base-keyring` may also be combined with
a local repository when a caller needs both.

## What the ARC job asserts

Both dry-run command lines are captured from
`$RUNNER_TEMP/melange-test-command.txt`. The job checks for `melange test`, the
manifest path, `--runner`, `--arch`, `--pipeline-dirs`,
`--test-package-append`, `--workspace-dir`, `--source-dir`, and the expected
`--repository-append` / `--keyring-append` flags. It also checks that neither
the command lines nor the action definition contain a build invocation.
