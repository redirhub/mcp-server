# Domain Connect: preparation kit

Working files for the **Connect DNS: Preparation runbook** (Notion, Product HQ → Connect DNS). They cover what can be prepared from code and public sources. Items that need production access, DNS credentials or an external account are listed under [Still to do](#still-to-do).

| File | Purpose |
|------|---------|
| `templates/hostname.json.tmpl` | Template for subdomains (`shop.example.com`): one CNAME. |
| `templates/apex.json.tmpl` | Template for root domains (`example.com`): A record plus the `rehd-verify=` TXT record. |
| `.env.example` | Provider ID, service IDs, key domain and the other `DC_*` settings. Copy it to `.env`, which is not committed. |
| `build.sh` | Writes the hard-coded submission files to `dist/<providerId>.<serviceId>.json` and lints them. |
| `dck-key.sh` | Prints the TXT records for a public key, checks them in DNS, and signs a sample query to test the full chain. |
| `logo.svg` | Brand-kit horizontal logo (from www.redirhub.com/brand) to attach to the Cloudflare email. |

The provider ID, service IDs and key domain are kept in env rather than in the repository. They are written into the JSON only by `build.sh`, when preparing the Templates PR:

```bash
cp .env.example .env        # fill in DC_PROVIDER_ID, DC_SERVICE_ID_*, DC_KEY_DOMAIN
DCTL=/path/to/dctl ./build.sh
# dist/<providerId>.<serviceId>.json  → root folder of the Domain-Connect/Templates PR
```

`logoUrl` defaults to the brand-kit SVG on CloudFront (`image/svg+xml`, versioned `v1` path), so the template and the Cloudflare email use the same logo.

## Change to the runbook: two templates, not two groups

The runbook plans one template (`redirhub.com.hostname`) with `sub` and `apex` groups. The Templates repository's linter rejects that design:

```
DCTL1012 record host must not be @ when template hostRequired is false
```

A CNAME on `@` is valid only when the template sets `hostRequired: true`. That flag then blocks root domains. So there are two templates:

- The hostname template (`DC_SERVICE_ID_HOSTNAME`) sets `hostRequired: true` and contains the CNAME.
- The apex template (`DC_SERVICE_ID_APEX`) contains the A and TXT records.

The backend picks the template from `mode` (sub / apex) that discovery already returns. The provider check in discovery (`/v2/domainTemplates/providers/{providerId}/services/{serviceId}`) must use the matching service ID. The backend should read these IDs from the same env names (`DOMAIN_CONNECT_*` in config).

## Checks run

With `.env` set to `redirhub.com`, `hostname` / `apex` and `redirhub.com`, both rendered templates pass these checks with no errors:

- The linter's `-merge-or-fail` mode (the Templates repository's auto-merge condition).
- The logo reachability check (`-logos`).
- JSON Schema validation against `template.schema`.

```bash
git clone https://github.com/Domain-Connect/dc-template-linter && (cd dc-template-linter && go build -o dctl .)
DCTL=dc-template-linter/dctl ./build.sh
dc-template-linter/dctl -cloudflare dist/*.json   # Cloudflare-specific notes
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
- **Cluster suffix:** `DC_CLUSTER_SUFFIX` defaults to `rediredge.com`. Live DNS supports it: `*.redirhub.com` points to `qzppjq.rediredge.com`, and test fixtures use the same shape. **Confirm this in production with `SELECT DISTINCT cname FROM cluster`.**
  - `database/seeders/ClusterHashCname.php` also lists older `*.urllize.com` values.
  - `Cluster::getHashCname()` returns non-wildcard cnames unchanged, with no hashid.
  - Any cluster whose cname is not `*.rediredge.com` needs its own template or must be excluded from Automatic setup.
- **Platform:** `txtRecordPrefix()` is built from `config('app.platform')` (default `REHD`). Both templates hard-code the `rehd-verify=` prefix, so Automatic setup must be turned off when `PLATFORM` is not `REHD`.
- **MX:** `Modules\Host\Enums\DnsRecord` has no MX case yet, which matches the spec requirement. There is no Domain Connect code in the backend yet.

## Key domain warning

If `DC_KEY_DOMAIN` is `redirhub.com`: that zone is on Cloudflare and has a **wildcard TXT record**. Today `_dck1.redirhub.com` and `_dck2.redirhub.com` both return `"vglvxl.rediredge.com"`. Publishing explicit `_dck1` records overrides the wildcard for that name. Until then, anything that fetches the key gets a wrong value. `dck-key.sh verify` ignores records that don't start with `p=`.

## Publishing the key

Generate the key on a trusted machine, not in CI or a shared container:

```bash
openssl genrsa -out dc_private.pem 2048
openssl rsa -in dc_private.pem -pubout -out dc_public.pem
./dck-key.sh records dc_public.pem          # add each line as a TXT record at ${DC_KEY_HOST}.${DC_KEY_DOMAIN}
./dck-key.sh verify dc_public.pem           # OK once DNS has propagated
./dck-key.sh selftest dc_private.pem        # signs a sample query and verifies it with the key from DNS
```

A 2048-bit key produces two records of about 200 characters each.

## Provider onboarding paths (checked 2026-09-30)

domainconnect.org says onboarding is done "by contacting them", and some providers "may require contractual terms". No primary source says any provider picks up templates from the repository automatically. Contacts marked *listed* come from domainconnect.org/dns-providers. None of them has been confirmed by the provider yet.

| Provider | Onboarding path | Notes |
|----------|-----------------|-------|
| Cloudflare | PR merged, then email `domain-connect@cloudflare.com` | Signing required; sync flow only. Can limit the template to a test account first. Updates are picked up within about 8 hours. |
| GoDaddy | `domainconnect@godaddy.com` (listed) | Third-party reports say GoDaddy sends new service providers to Entri, a paid intermediary. Expect a business relationship. Not confirmed by GoDaddy. |
| IONOS | `domain_connect_admin@domain.ionos.com` (listed) | No public onboarding docs. |
| Squarespace | Not confirmed | `domain-connect@squarespace.com` is the only lead, but it's listed for DNS providers onboarding Squarespace's own template, not for service providers. |
| NameSilo | `domainconnect@namesilo.com` (listed) | One third-party source says they sync from the public repository. Email them anyway. |
| WordPress.com | `registrar@automattic.com` (listed) | No developer docs. |
| Plesk | `domainconnect@plesk.com` (listed) | The Plesk extension reads templates from its own fork, `plesk/domain-connect-templates`, last updated in 2019. It needs an email or a PR there. It checks the signature when the template sets `syncPubKeyDomain`, and it only applies where Plesk hosts the DNS. |

Open question: Domain-Connect/Templates issue #385 ("Do DNS providers use this repository…?") has replies that weren't read. Check them before contacting providers.

## Still to do

Work is tracked in redirhub/backend#1290 (epic): backend #1291–#1297, lviv #254–#259, and ops checklist redirhub/backend#1298.


These items need access that the preparation work didn't have:

| Runbook item | Owner needs |
|--------------|-------------|
| Set the final provider ID, service IDs and key domain in `.env` before running `build.sh` for the PR | Product decision |
| Distinct cluster cnames, and production evidence for the spec (provider mix, share unverified after 24 hours and after 7 days) | Production database |
| Shared mailbox `domain-connect@redirhub.com` | Google Workspace admin |
| Generate the key, store `DOMAIN_CONNECT_PRIVATE_KEY`, publish `_dck1` | Trusted machine, production secrets, Cloudflare DNS for redirhub.com |
| Online editor tests (apex and subdomain), then the PR to Domain-Connect/Templates | Browser session. The PR goes from a fork under the company's GitHub account. |
| Emails to providers, test domains at GoDaddy and Cloudflare, staging workspace | External accounts, purchases |
