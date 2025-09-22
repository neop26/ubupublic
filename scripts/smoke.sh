#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARN:  $*" >&2; }
note() { echo "NOTE:  $*" >&2; }

# 1) Core presence
[ -f "$ROOT/config.sh" ] || fail "Missing config.sh"
[ -f "$ROOT/core/Global_functions.sh" ] || fail "Missing core/Global_functions.sh"
note "Core files present"

# 2) Extract module names from setup.sh
mods=()
while IFS= read -r line; do
  name="${line%%:*}"
  mods+=("$name")
done < <(awk '/^MODULES=\(/, /\)/ { if ($0 ~ /"[a-z0-9]+:.*"/) { gsub(/^[[:space:]]*"/, ""); gsub(/".*$/, ""); print } }' "$ROOT/setup.sh")

[ "${#mods[@]}" -gt 0 ] || fail "No modules found in setup.sh"

# 3) Check files exist per OS
missing=0
for os in ubuntu arch; do
  for m in "${mods[@]}"; do
    path="$ROOT/modules/$os/${m}.sh"
    if [ ! -f "$path" ]; then
      warn "Missing module for $os: $path"
      missing=$((missing+1))
    fi
  done
done
[ $missing -eq 0 ] || fail "Some modules are missing (${missing})"
note "All modules present for ubuntu and arch"

# 4) Syntax check
syntax_fail=0
while IFS= read -r -d '' f; do
  if ! bash -n "$f"; then
    warn "Syntax error: $f"
    syntax_fail=$((syntax_fail+1))
  fi
done < <(find "$ROOT/modules" -type f -name "*.sh" -print0)

[ $syntax_fail -eq 0 ] || fail "Syntax errors found (${syntax_fail})"
note "All module scripts pass bash -n"

# 5) Sourcing check (look for core sourcing) for declared modules only
sourcing_fail=0
for os in ubuntu arch; do
  for m in "${mods[@]}"; do
    f="$ROOT/modules/$os/${m}.sh"
    [ -f "$f" ] || continue
    if ! grep -q 'core/Global_functions.sh"' "$f"; then
      warn "No core sourcing found in: $f"
      sourcing_fail=$((sourcing_fail+1))
    fi
  done
done

[ $sourcing_fail -eq 0 ] || fail "Sourcing issues found (${sourcing_fail})"
note "All declared modules reference core/Global_functions.sh"

# 6) Optional: shellcheck (non-fatal)
if command -v shellcheck >/dev/null 2>&1; then
  note "Running shellcheck (non-fatal)..."
  shellcheck -x "$ROOT"/modules/ubuntu/*.sh || true
  shellcheck -x "$ROOT"/modules/arch/*.sh || true
else
  note "shellcheck not installed; skipping static analysis"
fi

echo "OK: Smoke tests passed"
