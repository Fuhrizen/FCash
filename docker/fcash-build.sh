#!/usr/bin/env bash
set -euo pipefail

cd /workspace

if [[ ! -f .hemtt/project.toml ]]; then
    echo "FCash builder: .hemtt/project.toml is missing from the image" >&2
    exit 66
fi

mkdir -p /output
if ! touch /output/.fcash-write-test 2>/dev/null; then
    echo "FCash builder: /output is not writable." >&2
    echo "The Compose bind mount should use SELinux private relabeling (Z)." >&2
    echo "If ./dist is not writable, remove it and run the build again." >&2
    exit 73
fi
rm -f /output/.fcash-write-test

echo "==> Building FCash PBO with HEMTT"
hemtt build "$@"

BUILD_DIR="/workspace/.hemttout/build"
if [[ ! -d "${BUILD_DIR}" ]]; then
    echo "FCash builder: HEMTT did not create ${BUILD_DIR}" >&2
    exit 70
fi

mkdir -p /output
rm -f /output/*.pbo /output/*.bisign

mapfile -t PBOS < <(find "${BUILD_DIR}" -type f -name '*.pbo' -print)
if [[ ${#PBOS[@]} -eq 0 ]]; then
    echo "FCash builder: no PBO was found under ${BUILD_DIR}" >&2
    find "${BUILD_DIR}" -maxdepth 5 -type f -print >&2 || true
    exit 71
fi

for pbo in "${PBOS[@]}"; do
    cp -f "${pbo}" /output/
    if [[ -f "${pbo}.bisign" ]]; then
        cp -f "${pbo}.bisign" /output/
    fi
done

if [[ -f /workspace/.hemttout/latest.log ]]; then
    cp -f /workspace/.hemttout/latest.log /output/hemtt.log
fi

echo "==> FCash PBO build complete"
printf '    %s\n' "${PBOS[@]##*/}"
echo "    Output directory: ./dist"
