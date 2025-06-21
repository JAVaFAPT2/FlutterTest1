#!/usr/bin/env bash
# Simple helper to bump build number in pubspec.yaml (patch increments)
# Usage: ./scripts/bump_version.sh 2
set -euo pipefail
BUILD=${1:-}
if [[ -z "$BUILD" ]]; then
  echo "Provide new build number"
  exit 1
fi
sed -i.bak -E "s/^(version: [0-9]+\.[0-9]+\.[0-9]+\+)[0-9]+/\1$BUILD/" pubspec.yaml
rm pubspec.yaml.bak
echo "pubspec.yaml build number set to $BUILD" 