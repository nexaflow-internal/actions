# Dry-run pool fixture for `apk-publish-index`

Small, hermetic stand-in for `nexaflow:<bucket>/main/x86_64` used only by the
`apk-publish-index` test job with `dry-run: 'true'` and
`dry-run-pool-path: <this directory>`.

Contents:

- `ca-certificates-20261020-r3.apk` and
  `ca-certificates-bundle-20261020-r3.apk` — minimal but real APK v3 archives
  (gzip tar with a `.PKGINFO` control entry). `melange index` parses the
  `.PKGINFO`, so `printf 'fixture'` placeholders do not work here.
- `APKINDEX.tar.gz` — a previously published index that carries an unrelated
  package (`wait-for-it`). The action's `--merge --source` path must preserve
  that entry while adding `ca-certificates`, which proves the merge path is
  exercised and no entry is dropped.

The action copies only `*.apk` and reads `APKINDEX.tar.gz`; this README and any
other files are ignored. Nothing here is ever uploaded — the CI job supplies no
S3 credentials, so a stray PUT would fail the job.
