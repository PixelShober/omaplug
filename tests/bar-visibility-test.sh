#!/bin/bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
cp "$ROOT/BarVisibility.qml" "$TMP/VisibilityHarness.qml"
cp "$ROOT/../BarVisibility.qml" "$TMP/BarVisibility.qml"
if ! OUTPUT=$(QT_QPA_PLATFORM=offscreen quickshell --no-color -p "$TMP/VisibilityHarness.qml" 2>&1); then
  printf '%s\n' "$OUTPUT"
  exit 1
fi
printf '%s\n' "$OUTPUT"
[[ $OUTPUT == *"bar-visibility-test: ok"* ]]
[[ $OUTPUT != *"FAIL"* && $OUTPUT != *"Failed to load configuration"* ]]
