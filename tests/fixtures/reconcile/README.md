# reconcile dry-run fixture

Local stand-in for `nexaflow:<bucket>/main/x86_64` used by the
`apk-reconcile` dry-run test in `.github/workflows/arc-wave1-test.yml`.
No S3 credentials and no network access are needed: with
`dry-run: 'true'` the action reads this directory directly instead of
rclone/curl.

- `APKINDEX.tar.gz` — plain gzip tar with an `APKINDEX` text file holding two
  entries: `fixture-alpha-1.0-r0` and `fixture-beta-2.0-r0`.
- `fixture-alpha-1.0-r0.apk`, `fixture-beta-2.0-r0.apk` — placeholders for the
  two indexed objects (check A must pass).
- `fixture-orphan-3.0-r0.apk` — present in the pool, absent from the index:
  check B must report exactly one orphan but must not fail the action.
- `withdrawn-packages.txt` — comment lines plus two names absent from the
  index (check C must pass).
- `nexaflow.rsa.pub` — stand-in for the served keyring file; in a dry run the
  action hashes this file instead of curling `base-url/keyring/nexaflow.rsa.pub`.
  Its SHA-256 is
  `07ebd09bdbb3b28435b3fba48d42c7527ea27023d2a7da1d9d66800fa5c7efd5`
  (check D). It is a fixture, not a nexaflow signing key.
- `generate.sh` — regenerates the apks and `APKINDEX.tar.gz` in place; the
  remaining files are checked in as text.

Expected dry-run summary: 2 index entries, 1 pool orphan.
