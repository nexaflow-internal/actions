# nexaflow-internal/actions

Public collection of GitHub Actions used by nexaflow CI. This repository is public and contains no secrets.

## Actions

| Action | Origin | Status |
| --- | --- | --- |
| [`wgetsum`](wgetsum/) | copied from `chainguard-dev/actions@805da2efdffdc42b8afd8880e575a48b471ef544` | available as `nexaflow-internal/actions/wgetsum@v0` |
| `setup-go` | nexaflow | planned, not published yet |
| [`setup-yam`](setup-yam/) | nexaflow; wraps `chainguard-dev/yam` | implemented, yam `v0.2.69`; not published yet |
| `setup-rclone` | nexaflow | planned, not published yet |

Only `wgetsum` is present today. The `setup-*` actions will be added in later tasks; they are listed here to document the intended layout of this repository.

## Attribution

`wgetsum/action.yaml` and `wgetsum/README.md` were copied from [chainguard-dev/actions](https://github.com/chainguard-dev/actions) at the pinned commit `805da2efdffdc42b8afd8880e575a48b471ef544`. Only the usage examples in the copied README were retargeted to this repository; the action code is unchanged. Upstream is licensed under Apache License 2.0, preserved verbatim in [LICENSE](LICENSE).

## Usage

Once published, our actions are referenced as:

```yaml
- uses: nexaflow-internal/actions/<name>@v1
```

Until `v1` is released, use `nexaflow-internal/actions/wgetsum@v0`. Note that the action shells out to `wget`, so the runner must have `wget` installed.
