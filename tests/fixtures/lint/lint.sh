#!/usr/bin/env bash

# Lint and format melange package manifests, mirroring the wolfi-dev/os
# conventions: package name must match the file name, no trailing
# whitespace, formatting normalized with `yam` when available.
#
# This is the registry's ONLY imperative script (docs/ci-cd-plan.md §0+):
# CI runs `make ci/lint`, which is exactly `LINT_CHECK=1 ./lint.sh <all>` —
# same code path, local == CI.
#
# Modes:
#   ./lint.sh [file.yaml ...]     — lint + reformat in place (dev mode)
#   LINT_CHECK=1 ./lint.sh ...    — check only, never touch files (CI mode);
#                                   also requires yam, and FAILs (not warns)
#                                   on the registry conventions below.

set -euo pipefail

LINT_CHECK="${LINT_CHECK:-0}"

stderr() {
    echo "$@" 1>&2
}

fail() {
    stderr "FAIL [$1]: $2"
    return 1
}

lint_one() {
    local fn="$1"
    local rc=0
    case "$fn" in
        *.yaml) ;;
        *) echo "--- $fn not a yaml file, skipping"
           return 0
    esac
    [ -f "$fn" ] || { stderr "FAIL: $fn does not exist"; return 1; }

    local name
    name=$(sed -n 's/^  name: *//p' "$fn" | head -n1)
    [ -n "$name" ] || { stderr "FAIL [$fn]: empty package name"; return 1; }
    echo "--- package" "$name"

    # package.name must match the file name (one package = one file).
    local expected="${fn%.yaml}"
    if [ "$name" != "$expected" ]; then
        stderr "FAIL [$fn]: package name '$name' does not match file name '$expected'"
        rc=1
    fi

    # Packages in this registry must not pin repositories or keyrings:
    # those come from the build environment (see Makefile). CI fails hard
    # (docs/ci-cd-plan.md §2.2); dev mode keeps the historic warning.
    if grep -qE '^[[:space:]]*(repositories|keyring):' "$fn"; then
        if [ "$LINT_CHECK" = 1 ]; then
            stderr "FAIL [$fn]: remove environment.contents.repositories/keyring (set by the Makefile)"
            rc=1
        else
            stderr "WARN [$fn]: remove environment.contents.repositories/keyring (set by the Makefile)"
        fi
    fi

    # git-checkout must always pin expected-commit (CLAUDE.md).
    if grep -q 'uses: git-checkout' "$fn" && ! grep -q 'expected-commit' "$fn"; then
        stderr "FAIL [$fn]: uses: git-checkout without expected-commit pin"
        rc=1
    fi

    # Every -doc subpackage must set options: no-depends: true — the SCA
    # attaches man-db to anything shipping man/info pages (CLAUDE.md).
    local doclines line lineno label
    doclines=$(grep -nE '^ *- name: [A-Za-z0-9._+-]+-doc$' "$fn" || true)
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        lineno=${line%%:*}
        label=$(printf '%s' "$line" | sed 's/^[0-9]*:  *- name: //')
        if ! sed -n "$((lineno+1)),$((lineno+12))p" "$fn" | grep -qE 'no-depends: *true'; then
            stderr "FAIL [$fn]: subpackage '$label' missing options: no-depends: true"
            rc=1
        fi
    done <<< "$doclines"

    # Patch files referenced via `uses: patch` must exist in the package's
    # sibling directory (<pkg>/<name>.patch). Heuristic: take *.patch tokens
    # from the lines following the pipeline step.
    local auxdir="${fn%.yaml}" patches p
    patches=$(grep -A8 'uses: patch' "$fn" | grep -oE '[^[:space:]]+\.patch' | sort -u || true)
    for p in $patches; do
        if [ ! -f "$auxdir/$p" ]; then
            stderr "FAIL [$fn]: patch file '$auxdir/$p' referenced but missing"
            rc=1
        fi
    done

    if grep -nE ' +$' "$fn" > /dev/null; then
        stderr "FAIL [$fn]: trailing whitespace found"
        grep -nE ' +$' "$fn" 1>&2 || true
        rc=1
    fi

    if command -v yam > /dev/null; then
        # yam CLI (chainguard-dev/yam v0.2.69): `yam <file>` formats in place,
        # `yam --lint <file>` check-only (fails on formatting drift, no writes)
        if [ "$LINT_CHECK" = 1 ]; then
            if ! yam --lint "$fn"; then
                stderr "FAIL [$fn]: formatting out of date — run: ./lint.sh $fn"
                rc=1
            fi
        else
            yam "$fn" || rc=1
        fi
    else
        if [ "$LINT_CHECK" = 1 ]; then
            stderr "FAIL [$fn]: CI mode requires yam (apk add yam)"
            rc=1
        else
            stderr "--- yam not installed, skipping format (install: apk add yam)"
        fi
    fi

    if [ "$rc" = 0 ]; then
        echo "--- OK $fn"
    fi
    return $rc
}

rc=0
if [ $# -eq 0 ]; then
    for fn in *.yaml; do
        [ -f "$fn" ] || continue
        lint_one "$fn" || rc=1
    done
else
    for fn in "$@"; do
        lint_one "$fn" || rc=1
    done
fi
exit $rc
