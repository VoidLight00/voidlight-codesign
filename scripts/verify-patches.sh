#!/usr/bin/env bash
# verify-patches.sh — patches/series 와 manifest 기본 일관성 검증
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/patches/manifest.json"
SERIES="$ROOT/patches/series"

if [ ! -f "$MANIFEST" ]; then
  echo "missing patches/manifest.json"
  exit 1
fi

if [ ! -f "$SERIES" ]; then
  echo "missing patches/series"
  exit 1
fi

node - <<'NODE' "$MANIFEST" "$SERIES"
const fs = require('fs');
const manifestPath = process.argv[2];
const seriesPath = process.argv[3];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const patches = Array.isArray(manifest.patches) ? manifest.patches : [];
const manifestFiles = new Set(patches.map((patch) => patch.file));
const seriesFiles = fs
  .readFileSync(seriesPath, 'utf8')
  .split(/\r?\n/)
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith('#'));

for (const patch of patches) {
  const required = ['id', 'file', 'tag', 'owner', 'risk', 'dependsOn', 'dropWhen', 'touches'];
  for (const key of required) {
    if (!(key in patch)) {
      throw new Error(`manifest patch ${patch.id || patch.file || '<unknown>'} missing ${key}`);
    }
  }
  if (!['PR_safe', 'Fork_only'].includes(patch.tag)) {
    throw new Error(`invalid patch tag for ${patch.file}: ${patch.tag}`);
  }
}

for (const file of seriesFiles) {
  if (!manifestFiles.has(file)) {
    throw new Error(`series contains patch not listed in manifest: ${file}`);
  }
}

for (const file of manifestFiles) {
  if (!seriesFiles.includes(file)) {
    throw new Error(`manifest contains patch not listed in series: ${file}`);
  }
}
NODE

missing=0
while IFS= read -r line; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  patch="$ROOT/patches/$line"
  if [ ! -f "$patch" ]; then
    echo "series references missing patch: $line"
    missing=1
  fi
done < "$SERIES"

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "OK — patch manifest/series 기본 검증 통과"
