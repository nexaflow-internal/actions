#!/usr/bin/env bash
# Build the tiny local pool used by the apk-reconcile dry-run test.
# The action only parses the APKINDEX text and checks pool object presence, so
# plain placeholder apks and a plain (unsigned) tar index are sufficient.
#
# usage: generate.sh <pool-dir>
set -euo pipefail

pool="${1:?usage: generate.sh <pool-dir>}"
mkdir -p "$pool"

for apk in \
  fixture-alpha-1.0-r0.apk \
  fixture-beta-2.0-r0.apk \
  fixture-orphan-3.0-r0.apk; do
  printf 'fixture placeholder for %s\n' "$apk" > "$pool/$apk"
done

cat > "$pool/APKINDEX" <<'EOF'
C:Q1fixturealphaindex
P:fixture-alpha
V:1.0-r0
A:x86_64
S:35
I:35
T:fixture alpha for apk-reconcile dry run
U:
L:MPL-2.0

C:Q1fixturebetaindex
P:fixture-beta
V:2.0-r0
A:x86_64
S:35
I:35
T:fixture beta for apk-reconcile dry run
U:
L:MPL-2.0

EOF

tar czf "$pool/APKINDEX.tar.gz" -C "$pool" APKINDEX
rm "$pool/APKINDEX"

echo "generate.sh: pool=$pool"
ls -l "$pool"
