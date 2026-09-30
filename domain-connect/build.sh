#!/usr/bin/env bash
# Render templates/*.json.tmpl with the DC_* settings from .env (or the environment)
# into dist/<providerId>.<serviceId>.json, the hard-coded files submitted to
# github.com/Domain-Connect/Templates. Then lint them if dctl is available.
#
#   ./build.sh            render + lint (set DCTL=/path/to/dctl, or have dctl on PATH)
set -euo pipefail
cd "$(dirname "$0")"

if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    . ./.env
    set +a
fi

required="DC_PROVIDER_ID DC_SERVICE_ID_HOSTNAME DC_SERVICE_ID_APEX DC_KEY_DOMAIN DC_REDIRECT_DOMAIN DC_CLUSTER_SUFFIX DC_LOGO_URL"
missing=""
for v in $required; do
    [ -n "${!v:-}" ] || missing="$missing $v"
done
if [ -n "$missing" ]; then
    echo "Missing settings:$missing (copy .env.example to .env)" >&2
    exit 1
fi
export $required

rm -rf dist && mkdir dist
for tmpl in templates/*.json.tmpl; do
    python3 - "$tmpl" <<'PY'
import json, os, re, sys

src = open(sys.argv[1]).read()
out = re.sub(r"\$\{(DC_[A-Z_]+)\}", lambda m: os.environ[m.group(1)], src)
tpl = json.loads(out)
path = f"dist/{tpl['providerId']}.{tpl['serviceId']}.json"
open(path, "w").write(out)
print(path)
PY
done

dctl=${DCTL:-$(command -v dctl || true)}
if [ -z "$dctl" ]; then
    echo "dctl not found; skipped lint (see README)" >&2
    exit 0
fi
"$dctl" -merge-or-fail -logos dist/*.json
echo "Lint OK"
