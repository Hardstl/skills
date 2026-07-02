#!/usr/bin/env bash
set -u

target="${1:-.}"

if [ ! -e "$target" ]; then
  echo "error: target does not exist: $target" >&2
  exit 2
fi

files_list="$(mktemp)"
refs_list="$(mktemp)"
trap 'rm -f "$files_list" "$refs_list"' EXIT

if [ -d "$target" ]; then
  find "$target" -type f -name '*.bicep' -not -path '*/.bicep/*' | sort > "$files_list"
else
  printf '%s\n' "$target" > "$files_list"
fi

if [ ! -s "$files_list" ]; then
  echo "error: no .bicep files found under $target" >&2
  exit 2
fi

fail=0

blocker() {
  fail=1
  printf 'blocker: %s\n' "$1" >&2
}

check_file() {
  file="$1"

  while IFS= read -r line; do
    blocker "$file:$line uses a local or absolute module path; use direct br/public:avm references for AVM-covered resources"
  done < <(grep -En "^[[:space:]]*module[[:space:]]+[A-Za-z0-9_]+[[:space:]]+'(\./|\.\./|/)" "$file")

  grep -En "br/public:avm/" "$file" > "$refs_list"
  while IFS= read -r line; do
    printf '%s\n' "$line" | grep -Eq "br/public:avm/[^']+:[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.-]+)?'" || \
      blocker "$file:$line uses an AVM reference without an explicit pinned semver version"
  done < "$refs_list"

  if [ -s "$refs_list" ]; then
    grep -Eq "^[[:space:]]*param[[:space:]]+projectName[[:space:]]+string([[:space:]=]|$)" "$file" || \
      blocker "$file is missing required baseline parameter: param projectName string"
    grep -Eq "^[[:space:]]*param[[:space:]]+environment[[:space:]]+string([[:space:]=]|$)" "$file" || \
      blocker "$file is missing required baseline parameter: param environment string"
  fi

  while IFS= read -r line; do
    blocker "$file:$line uses standalone role-assignment or private-endpoint AVM modules; prefer producer-owned roleAssignments/privateEndpoints"
  done < <(grep -En "^[[:space:]]*module[[:space:]]+[A-Za-z0-9_]+[[:space:]]+'br/public:avm/res/(authorization/role-assignment|network/private-endpoint):" "$file")

  while IFS= read -r line; do
    line_number="${line%%:*}"
    start=$((line_number - 3))
    if [ "$start" -lt 1 ]; then
      start=1
    fi
    if ! sed -n "${start},${line_number}p" "$file" | grep -Eq "avm-author:[[:space:]]*native-exception[[:space:]]+."; then
      blocker "$file:$line creates a non-existing native resource without a nearby // avm-author: native-exception <reason> comment"
    fi
  done < <(grep -En "^[[:space:]]*resource[[:space:]]+[A-Za-z0-9_]+[[:space:]]+'Microsoft\\.[^']+@" "$file" | grep -Ev "=[[:space:]]*existing[[:space:]]*\{")

  while IFS= read -r line; do
    line_number="${line%%:*}"
    start=$((line_number - 3))
    if [ "$start" -lt 1 ]; then
      start=1
    fi
    if ! sed -n "${start},${line_number}p" "$file" | grep -Eq "avm-author:[[:space:]]*depends-on-exception[[:space:]]+."; then
      blocker "$file:$line uses explicit dependsOn without a nearby // avm-author: depends-on-exception <reason> comment"
    fi
  done < <(grep -En "^[[:space:]]*dependsOn[[:space:]]*:" "$file")

  while IFS= read -r line; do
    blocker "$file:$line contains an unresolved AVM version placeholder"
  done < <(grep -En "br/public:avm/.*:(TODO|latest|<version>|0\.0\.0)" "$file")

  while IFS= read -r line; do
    blocker "$file:$line sets privateEndpointNetworkPolicies to a value other than 'Enabled'"
  done < <(grep -En "privateEndpointNetworkPolicies[[:space:]]*:[[:space:]]*'[^']+'" "$file" | grep -Ev "privateEndpointNetworkPolicies[[:space:]]*:[[:space:]]*'Enabled'")
}

while IFS= read -r file; do
  check_file "$file"
done < "$files_list"

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "pass: AVM authoring posture checks passed"
