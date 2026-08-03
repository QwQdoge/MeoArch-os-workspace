#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/source"
mkdir -p "${evidence_dir}"
exec > >(tee "${evidence_dir}/source-validation.log") 2>&1
cd "${repo_root}"

required=(
  meoarch-os/profiledef.sh
  meoarch-os/packages.x86_64
  installer/qml/Main.qml
  installer/backend/generate-config.py
  meo-desktop/packaging/arch/PKGBUILD
  themes/MeoUI/CMakeLists.txt
)
for path in "${required[@]}"; do
  [ -f "${path}" ] || { echo "Missing ${path}" >&2; exit 1; }
done

if find meoarch-os/airootfs -path '*/opt/meo-ui*' -print -quit | grep -q .; then
  echo "Obsolete /opt/meo-ui payload exists." >&2
  exit 1
fi
grep -q 'qt_add_qml_module(meoui_module' themes/MeoUI/CMakeLists.txt
grep -A5 'qt_add_qml_module(meoui_module' themes/MeoUI/CMakeLists.txt | grep -q 'SHARED'
grep -q 'SOVERSION 0' themes/MeoUI/CMakeLists.txt
grep -q '"schemaVersion": 1' installer/data/default_selections.json

duplicates="$(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' meoarch-os/packages.x86_64 |
  sort | uniq -d)"
if [ -n "${duplicates}" ]; then
  echo "Duplicate packages:"
  echo "${duplicates}"
  exit 1
fi

python -m unittest discover -s installer/tests -v
find scripts installer meo-desktop -type f -name '*.sh' -print0 |
  xargs -0 -n1 bash -n
python - <<'PY'
import json
from pathlib import Path
for root in ("installer", "meo-desktop", "meoarch-os"):
    for path in Path(root).rglob("*.json"):
        with path.open(encoding="utf-8") as handle:
            json.load(handle)
PY
git diff --check
echo "PASS: source validation" | tee "${evidence_dir}/status.txt"
