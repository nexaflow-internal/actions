# nexaflow-internal/actions

Public collection of GitHub Actions used by nexaflow CI. The set is a selective copy of Chainguard's actions (with attribution preserved below) plus small nexaflow-specific adapters. Actions are deliberately granular — one concern each, no god-object hiding the whole pipeline. `melange-build` builds, indexes and tests one melange package and replaces `make ci/build` in the `packages` registry. This repository is public and contains no secrets.

## Actions

| Action | Origin | Published as |
| --- | --- | --- |
| [`wgetsum`](wgetsum/) | copied from `chainguard-dev/actions@805da2efdffdc42b8afd8880e575a48b471ef544` | `nexaflow-internal/actions/wgetsum@v0` |
| [`setup-go`](setup-go/) | nexaflow | `nexaflow-internal/actions/setup-go@v1` |
| [`setup-yam`](setup-yam/) | nexaflow; wraps `chainguard-dev/yam` (yam `v0.2.69`) | `nexaflow-internal/actions/setup-yam@v1` |
| [`setup-rclone`](setup-rclone/) | nexaflow; downloads rclone via `wgetsum` (rclone `1.60.1`) | `nexaflow-internal/actions/setup-rclone@v1` |
| [`setup-melange`](setup-melange/) | nexaflow; installs `chainguard-dev/melange` (melange `0.64.0`) | `nexaflow-internal/actions/setup-melange@v2` |
| [`setup-bubblewrap`](setup-bubblewrap/) | nexaflow | `nexaflow-internal/actions/setup-bubblewrap@v2` |
| [`melange-build`](melange-build/) | nexaflow; replaces `make ci/build` | `nexaflow-internal/actions/melange-build@v2` |

## Attribution

`wgetsum/action.yaml` and `wgetsum/README.md` were copied from [chainguard-dev/actions](https://github.com/chainguard-dev/actions) at the pinned commit `805da2efdffdc42b8afd8880e575a48b471ef544`. Only the usage examples in the copied README were retargeted to this repository; the action code is unchanged. Upstream is licensed under Apache License 2.0, preserved verbatim in [LICENSE](LICENSE). The remaining actions are nexaflow-authored; `setup-yam` and `setup-melange` install upstream Chainguard tools rather than copying their code.

## Usage

Published actions are referenced as:

```yaml
- uses: nexaflow-internal/actions/wgetsum@v0
- uses: nexaflow-internal/actions/setup-go@v1
- uses: nexaflow-internal/actions/setup-yam@v1
- uses: nexaflow-internal/actions/setup-rclone@v1
- uses: nexaflow-internal/actions/setup-melange@v2
- uses: nexaflow-internal/actions/setup-bubblewrap@v2
- uses: nexaflow-internal/actions/melange-build@v2
```

`wgetsum` remains pinned to `v0` to preserve the upstream import; `setup-go`, `setup-yam` and `setup-rclone` use `v1`; `setup-melange`, `setup-bubblewrap` and `melange-build` share `v2`. Documentation/CI-only changes after a tag are not republished. Note that `wgetsum` shells out to `wget`, so the runner must have `wget` installed.
