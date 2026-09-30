#!/usr/bin/env bash
# Domain Connect signing key helper.
#
#   ./dck-key.sh records <public.pem>                    Print the TXT records to publish at _dck1.<key domain>
#   ./dck-key.sh verify  <public.pem> [host]             Check the published records reassemble into <public.pem>
#   ./dck-key.sh selftest <private.pem> [host]           Sign a sample apply query and verify it with the key from DNS
#
# host defaults to ${DC_KEY_HOST}.${DC_KEY_DOMAIN} from .env. Run on a trusted machine; never commit the private key.
set -euo pipefail

if [ -f "$(dirname "$0")/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    . "$(dirname "$0")/.env"
    set +a
fi

CHUNK=200
HOST_DEFAULT="${DC_KEY_HOST:-_dck1}.${DC_KEY_DOMAIN:-}"

pubkey_b64() {
    openssl pkey -pubin -in "$1" -outform DER | openssl base64 -A
}

txt_lookup() {
    if command -v dig >/dev/null; then
        dig +short TXT "$1" | tr -d '"'
    else
        curl -fsS "https://dns.google/resolve?name=$1&type=TXT" \
            | python3 -c 'import json,sys; [print(a["data"].strip("\"")) for a in json.load(sys.stdin).get("Answer",[]) if a["type"]==16]'
    fi
}

# Reassemble "p=N,a=RS256,d=..." records in part order.
dns_b64() {
    txt_lookup "$1" | grep -E '^p=[0-9]+,' | sort -t= -k2 -n | sed -E 's/.*,d=//' | tr -d ' \n'
}

cmd=${1:-}
case "$cmd" in
records)
    b64=$(pubkey_b64 "$2")
    i=1
    while [ -n "$b64" ]; do
        echo "p=$i,a=RS256,d=${b64:0:$CHUNK}"
        b64=${b64:$CHUNK}
        i=$((i + 1))
    done
    ;;
verify)
    host=${3:-$HOST_DEFAULT}
    [ "${host%.}" != "$host" ] && { echo "Set DC_KEY_DOMAIN in .env or pass the key host" >&2; exit 2; }
    want=$(pubkey_b64 "$2")
    got=$(dns_b64 "$host")
    if [ "$want" = "$got" ]; then
        echo "OK: $host matches $2"
    else
        echo "MISMATCH at $host (published ${#got} chars, expected ${#want})" >&2
        exit 1
    fi
    ;;
selftest)
    host=${3:-$HOST_DEFAULT}
    [ "${host%.}" != "$host" ] && { echo "Set DC_KEY_DOMAIN in .env or pass the key host" >&2; exit 2; }
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    query="domain=example.com&host=shop&hashid=abc123&redirect_uri=https%3A%2F%2Fdash.redirhub.com%2Fdomain-connect%2Fcallback"
    printf '%s' "$query" >"$tmp/query"
    openssl dgst -sha256 -sign "$2" -out "$tmp/sig" "$tmp/query"
    {
        echo "-----BEGIN PUBLIC KEY-----"
        dns_b64 "$host" | fold -w 64
        echo
        echo "-----END PUBLIC KEY-----"
    } >"$tmp/dns.pem"
    openssl dgst -sha256 -verify "$tmp/dns.pem" -signature "$tmp/sig" "$tmp/query"
    echo "Signed URL suffix: &sig=$(openssl base64 -A <"$tmp/sig" | python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=""))')&key=${host%%.*}"
    ;;
*)
    sed -n '2,8p' "$0"
    exit 2
    ;;
esac
