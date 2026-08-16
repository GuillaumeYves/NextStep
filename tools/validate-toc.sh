#!/usr/bin/env bash
set -euo pipefail

toc_path="${1:-NextStep.toc}"
if [[ ! -f "$toc_path" ]]; then
    echo "Manifest not found: $toc_path" >&2
    exit 1
fi

declare -A seen_paths=()
file_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    file_path="${line//\\//}"
    if [[ ! -f "$file_path" ]]; then
        echo "Manifest entry not found: $line" >&2
        exit 1
    fi
    if [[ -n "${seen_paths[$file_path]+present}" ]]; then
        echo "Duplicate manifest entry: $line" >&2
        exit 1
    fi

    seen_paths[$file_path]=1
    file_count=$((file_count + 1))
done < "$toc_path"

if [[ "$file_count" -eq 0 ]]; then
    echo "Manifest contains no addon files." >&2
    exit 1
fi

echo "Validated $file_count manifest entries."
