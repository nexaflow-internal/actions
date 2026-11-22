# nexaflow-internal/actions

Public collection of GitHub Actions used by nexaflow CI. This repository is public and contains no secrets.

## Actions

| Action | Origin | Status |
| --- | --- | --- |
| [`wgetsum`](wgetsum/) | copied from `chainguard-dev/actions@805da2efdffdc42b8afd8880e575a48b471ef544` | published as `nexaflow-internal/actions/wgetsum@v0` |
| [`setup-go`](setup-go/) | nexaflow | published as `nexaflow-internal/actions/setup-go@v1` |
| [`setup-yam`](setup-yam/) | nexaflow; wraps `chainguard-dev/yam` | published as `nexaflow-internal/actions/setup-yam@v1` (yam `v0.2.69`) |
| [`setup-rclone`](setup-rclone/) | nexaflow; downloads rclone via `wgetsum` | published as `nexaflow-internal/actions/setup-rclone@v1` (rclone `1.60.1`) |

All four actions above are present in this repository and published under the tags shown. More actions will be added in later waves.

## Attribution

`wgetsum/action.yaml` and `wgetsum/README.md` were copied from [chainguard-dev/actions](https://github.com/chainguard-dev/actions) at the pinned commit `805da2efdffdc42b8afd8880e575a48b471ef544`. Only the usage examples in the copied README were retargeted to this repository; the action code is unchanged. Upstream is licensed under Apache License 2.0, preserved verbatim in [LICENSE](LICENSE).

## Usage

Published actions are referenced as:

```yaml
- uses: nexaflow-internal/actions/wgetsum@v0
- uses: nexaflow-internal/actions/setup-go@v1
- uses: nexaflow-internal/actions/setup-yam@v1
- uses: nexaflow-internal/actions/setup-rclone@v1
```

`wgetsum` remains pinned to `v0` to preserve the upstream import; the `setup-*` actions use `v1`. Documentation/CI-only changes after a tag are not republished. Note that `wgetsum` shells out to `wget`, so the runner must have `wget` installed.
