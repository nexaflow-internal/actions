#!/usr/bin/env bash
# Regression test: apk-upload-pool must treat `rclone size --json` reporting
# {"bytes":0,"count":0} as "object absent" and PUT it, not as an immutable
# apk that already exists with size 0.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
action="$repo_root/apk-upload-pool/action.yml"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

command -v python3 >/dev/null || { echo "python3 required" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 2; }

# Extract the run: | block of the "Upload package apks" step from the real
# composite action so we test the shipped code, not a copy of it.
python3 - "$action" > "$tmp/upload.sh" <<'PY'
import sys
lines = open(sys.argv[1]).read().splitlines()
in_step = False
in_run = False
out = []
for line in lines:
    if line.strip() == '- name: Upload package apks':
        in_step = True
        continue
    if in_step and line.strip() == 'run: |':
        in_run = True
        continue
    if in_run:
        if line and not line.startswith('        '):
            break
        if line.startswith('        '):
            out.append(line[8:])
print('\n'.join(out))
PY
test -s "$tmp/upload.sh"

mkdir -p "$tmp/bin" "$tmp/repo/x86_64"
cat > "$tmp/bin/melange" <<'EOF'
#!/bin/sh
# No subpackages — only the main package name is discovered.
printf '\n'
EOF
cat > "$tmp/bin/rclone" <<EOF
#!/bin/sh
for arg in "\$@"; do
  case "\$arg" in
    size)
      # S3 object storage reports a missing key as an empty listing.
      printf '{"bytes":0,"count":0}\n'
      exit 0
      ;;
    copyto)
      printf 'PUT %s\n' "\$*" >> "$tmp/puts.txt"
      exit 0
      ;;
  esac
done
exit 0
EOF
chmod +x "$tmp/bin/melange" "$tmp/bin/rclone"

printf 'fixture\n' > "$tmp/repo/x86_64/ca-certs-1.0-r0.apk"
printf 'name: ca-certs\n' > "$tmp/ca-certs.yaml"

export PATH="$tmp/bin:$PATH"
export PACKAGE=ca-certs
export REPOSITORY_PATH="$tmp/repo"
export ARCH=x86_64
export DRY_RUN=false
export S3_ENDPOINT=https://s3.invalid
export S3_BUCKET=test-bucket
export S3_ACCESS_KEY_ID=fake
export S3_SECRET_ACCESS_KEY=fake

cd "$tmp"
set +e
bash "$tmp/upload.sh" > "$tmp/out.txt" 2>&1
rc=$?
set -e
cat "$tmp/out.txt"

if grep -q 'exists in pool with size 0' "$tmp/out.txt"; then
  echo "FAIL: missing object (count=0, bytes=0) was treated as an existing apk" >&2
  exit 1
fi
if ! grep -q 'PUT ca-certs-1.0-r0.apk' "$tmp/out.txt"; then
  echo "FAIL: missing object was not uploaded" >&2
  exit 1
fi
if [ "$rc" -ne 0 ]; then
  echo "FAIL: action exited $rc" >&2
  exit 1
fi
test -f "$tmp/puts.txt" || { echo "FAIL: copyto was never called" >&2; exit 1; }

# The immutable check must still work for objects that really exist.
rm -f "$tmp/puts.txt" "$tmp/out.txt"
cat > "$tmp/bin/rclone" <<EOF
#!/bin/sh
for arg in "\$@"; do
  case "\$arg" in
    size)
      printf '{"bytes":8,"count":1}\n'
      exit 0
      ;;
    copyto)
      printf 'PUT %s\n' "\$*" >> "$tmp/puts.txt"
      exit 0
      ;;
  esac
done
exit 0
EOF
chmod +x "$tmp/bin/rclone"
set +e
bash "$tmp/upload.sh" > "$tmp/out.txt" 2>&1
rc=$?
set -e
cat "$tmp/out.txt"
if ! grep -q 'already published, skip' "$tmp/out.txt"; then
  echo "FAIL: existing apk with matching size was not skipped" >&2
  exit 1
fi
if [ -e "$tmp/puts.txt" ]; then
  echo "FAIL: existing apk was re-uploaded" >&2
  exit 1
fi
[ "$rc" -eq 0 ] || { echo "FAIL: action exited $rc on existing apk" >&2; exit 1; }

echo "apk-upload-pool missing-object test: OK"
