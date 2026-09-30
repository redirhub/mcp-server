# Domain Connect: preparation kit

Working files for the **Connect DNS: Preparation runbook** (Notion, Product HQ → Connect DNS). They cover what can be prepared from code and public sources. Items that need production access, DNS credentials or an external account are listed under [Still to do](#still-to-do).

| File | Purpose |
|------|---------|
| `redirhub.com.hostname.json` | Template for subdomains (`shop.example.com`): one CNAME. |
| `redirhub.com.apex.json` | Template for root domains (`example.com`): A record plus the `rehd-verify=` TXT record. |
| `dck-key.sh` | Prints the `_dck1` TXT records for a public key, checks them in DNS, and signs a sample query to test the full chain. |

## Change to the runbook: two templates, not two groups

The runbook plans one template (`redirhub.com.hostname`) with `sub` and `apex` groups. The Templates repository's linter rejects that design:

```
DCTL1012 record host must not be @ when template hostRequired is false
```

A CNAME on `@` is valid only when the template sets `hostRequired: true`. That flag then blocks root domains. So there are two templates:

- `redirhub.com.hostname` sets `hostRequired: true` and contains the CNAME.
- `redirhub.com.apex` contains the A and TXT records.

The backend picks the template from `mode` (sub / apex) that discovery already returns. The provider check in discovery (`/v2/domainTemplates/providers/redirhub.com/services/{serviceId}`) must use the matching service ID.

## Checks run

Both templates pass these checks with no errors:

- The linter's `-merge-or-fail` mode (the Templates repository's auto-merge condition).
- The logo reachability check (`-logos`).
- JSON Schema validation against `template.schema`.

```bash
git clone https://github.com/Domain-Connect/dc-template-linter && cd dc-template-linter && go build -o dctl .
./dctl -merge-or-fail -logos ../redirhub.com.*.json
./dctl -cloudflare ../redirhub.com.*.json   # Cloudflare-specific notes
```

Cloudflare mode prints notes. They don't block the templates, but engineering must plan for them:

| Cloudflare note | Effect |
|-----------------|--------|
| `essential` is not supported | Cloudflare ignores it. No action needed. |
| `txtConflictMatchingMode` is not supported | An old `rehd-verify=` TXT is not replaced, so the new one is added next to it. Verification still passes because the backend matches any TXT that has our value. |
| `hostRequired` is not supported | Cloudflare won't enforce `host`. The apply endpoint (not built yet) must always send `host` with the `hostname` template. |
| `syncRedirectDomain` is not supported | Already known. Cloudflare uses the signed `redirect_uri`. |
| CNAME flattening | Only affects CNAMEs on the apex. The apex template uses an A record instead. |

## Phase 0 answers (from `redirhub/backend`)

- **Records come from `HostDnsInfo::require()`.**
  - The CNAME is `Cluster::getHashCname($org)`. When the cluster's `cname` is a wildcard (`*.suffix`), the `*` is replaced with the **workspace** hashid, not a per-host ID. So `%hashid%` is the organization's `hashid()`.
  - The TXT value is `Host::txtRecordPrefix()` followed by the same CNAME, which gives `rehd-verify=<hashid>.<suffix>` on REHD.
  - The A record value is `cluster->ip`.
- **Cluster suffix:** the templates use `rediredge.com`. Live DNS supports it: `*.redirhub.com` points to `qzppjq.rediredge.com`, and test fixtures use the same shape. **Confirm this in production with `SELECT DISTINCT cname FROM cluster`.**
  - `database/seeders/ClusterHashCname.php` also lists older `*.urllize.com` values.
  - `Cluster::getHashCname()` returns non-wildcard cnames unchanged, with no hashid.
  - Any cluster whose cname is not `*.rediredge.com` needs its own template or must be excluded from Automatic setup.
- **Platform:** `txtRecordPrefix()` is built from `config('app.platform')` (default `REHD`). Both templates hard-code `rehd-verify=`, so Automatic setup must be turned off when `PLATFORM` is not `REHD`.
- **MX:** `Modules\Host\Enums\DnsRecord` has no MX case yet, which matches the spec requirement. There is no Domain Connect code in the backend yet.

## Key domain warning

`redirhub.com` is on Cloudflare and has a **wildcard TXT record**. Today `_dck1.redirhub.com` and `_dck2.redirhub.com` both return `"vglvxl.rediredge.com"`. Publishing explicit `_dck1` records overrides the wildcard for that name. Until then, anything that fetches the key gets a wrong value. `dck-key.sh verify` ignores records that don't start with `p=`.

## Publishing the key

Generate the key on a trusted machine, not in CI or a shared container:

```bash
openssl genrsa -out dc_private.pem 2048
openssl rsa -in dc_private.pem -pubout -out dc_public.pem
./dck-key.sh records dc_public.pem          # add each line as a TXT record at _dck1.redirhub.com (DNS only)
./dck-key.sh verify dc_public.pem           # OK once DNS has propagated
./dck-key.sh selftest dc_private.pem        # signs a sample query and verifies it with the key from DNS
```

A 2048-bit key produces two records of about 200 characters each.

## Still to do

These items need access that the preparation work didn't have:

| Runbook item | Owner needs |
|--------------|-------------|
| Confirm the provider ID, service IDs and key domain (the drafts use `redirhub.com`, `hostname` / `apex`, `redirhub.com`) | Product decision |
| Distinct cluster cnames, and production evidence for the spec (provider mix, share unverified after 24 hours and after 7 days) | Production database |
| Shared mailbox `domain-connect@redirhub.com` | Google Workspace admin |
| Generate the key, store `DOMAIN_CONNECT_PRIVATE_KEY`, publish `_dck1` | Trusted machine, production secrets, Cloudflare DNS for redirhub.com |
| SVG logo for Cloudflare (the templates use the site's PNG, `logo.png`) | Brand asset |
| Online editor tests (apex and subdomain), then the PR to Domain-Connect/Templates | Browser session. The PR goes from a fork under the company's GitHub account. |
| Emails to providers, test domains at GoDaddy and Cloudflare, staging workspace | External accounts, purchases |
| Issues in redirhub/backend and redirhub/lviv | Can be opened on request |
