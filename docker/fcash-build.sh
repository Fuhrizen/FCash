#!/usr/bin/env bash
set -euo pipefail

cd /workspace

fail() {
    echo "FCash release builder: $*" >&2
    exit 1
}

PROJECT_FILE=".hemtt/project.toml"
RELEASE_DIR="/workspace/.hemttout/release"

[[ -f "${PROJECT_FILE}" ]] || fail "${PROJECT_FILE} is missing"
mkdir -p /output

if ! touch /output/.fcash-write-test 2>/dev/null; then
    fail "./dist is not writable. Remove it and run the build again."
fi
rm -f /output/.fcash-write-test

if [[ -d .git ]]; then
    git config --global --add safe.directory /workspace >/dev/null 2>&1 || true
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        if ! git rev-parse HEAD >/dev/null 2>&1; then
            fail "the Git repository has no commit"
        fi
        if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
            echo "FCash release builder: release source contains uncommitted changes:" >&2
            git status --short >&2
            echo "Commit the release source before building a signed package." >&2
            exit 65
        fi
    fi
fi

echo "==> Static validation"
python3 tools/static_check.py

echo "==> Signed HEMTT release"
# HEMTT generates the BI private/public signing material required for this
# release automatically. No interactive key-generation step is used here.
hemtt release "$@"

[[ -d "${RELEASE_DIR}" ]] || fail "HEMTT did not create ${RELEASE_DIR}"

mapfile -t PBOS < <(find "${RELEASE_DIR}" -type f -name '*.pbo' -print)
mapfile -t SIGS < <(find "${RELEASE_DIR}" -type f -name '*.bisign' -print)
mapfile -t KEYS < <(find "${RELEASE_DIR}" -type f -name '*.bikey' -print)

(( ${#PBOS[@]} > 0 )) || fail "release contains no PBO"
(( ${#SIGS[@]} > 0 )) || fail "release contains no BISIGN"
(( ${#KEYS[@]} > 0 )) || fail "release contains no BIKEY"

find /output -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "${RELEASE_DIR}/." /output/

if [[ -f /workspace/.hemttout/latest.log ]]; then
    cp -f /workspace/.hemttout/latest.log /output/hemtt.log
fi

(
    cd /output
    find . -type f \( -name '*.pbo' -o -name '*.bisign' -o -name '*.bikey' \) -print0 \
        | sort -z \
        | xargs -0 sha256sum > SHA256SUMS.txt
)

echo "==> FCash signed release complete"
echo "    PBOs:    ${#PBOS[@]}"
echo "    BISIGNs: ${#SIGS[@]}"
echo "    BIKEYs:  ${#KEYS[@]}"
echo "    Output:  ./dist"
