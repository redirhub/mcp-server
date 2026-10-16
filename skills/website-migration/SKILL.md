---
name: website-migration
description: Plan and run a website migration with RedirHub — collect the old URLs, map each one to its new URL, import the 301 redirects as a reviewed dry run, check the old domain's DNS, and verify after launch. Use when someone is moving a site to a new domain, platform or URL structure, retiring a domain, or asks how to avoid broken links and lost SEO during a migration.
---

# Website migration with RedirHub

Goal: every old URL that had traffic or links lands on the right new page with a permanent redirect, and nothing changes in the user's workspace until they have seen and approved it.

Work through the steps in order. Keep the user in the loop at each checkpoint marked **Confirm**.

## 1. Scope the move

Ask only what you don't already know:

- Old domain(s) and new domain(s), e.g. `old-shop.com` → `www.newshop.com`.
- Is the path structure changing, or only the domain? If only the domain changes, one domain redirect with path forwarding may be enough (see step 3a).
- Where the old URLs come from: a sitemap, a CMS export, a CSV/spreadsheet, an analytics export, or a pasted list.

Call `get-workspace` to confirm which workspace you are working in, and `list-hosts` to see whether the old domain is already connected.

## 2. Build the URL map

1. Collect the old URLs from what the user provides. Normalize them: drop the protocol, keep host + path (`old-shop.com/products/blue-mug`), keep query strings only when they select different content.
2. Map each old URL to a new URL:
   - Apply the user's rules first (e.g. `/blog/YYYY/MM/slug` → `/blog/slug`, `/products/` → `/shop/`).
   - Match remaining pages by slug or title.
   - Pages with no equivalent go to the closest parent page (category, section), never all to the home page.
3. Flag for the user, as a short list:
   - Old URLs with no confident match.
   - Many old URLs pointing to one new URL (can be fine, but say so).
   - Chains or loops (A → B while B → C, or A → A).

**Confirm** the map with the user. Show counts and the flagged rows, not every row.

## 3. Create the redirects

### 3a. Domain-only move

If only the domain changes and paths stay the same, use `create-redirect` on the old domain with `type: "301"`, `forward_path: true` and `forward_query: true`. One record covers every path.

### 3b. Path changes (the usual case)

Use `bulk-import` with one row per old URL:

```json
{ "url": "old-shop.com/products/blue-mug", "destination": "https://www.newshop.com/shop/blue-mug", "handler": "migration", "type": "301" }
```

1. Run it as a dry run first (the default). Report `valid`, `invalid` and the `errors`, and fix the invalid rows with the user.
2. `mode: "create"` (default) skips old URLs that already have a record. Use `mode: "upsert"` only when the user wants existing records replaced; it needs the `confirmation_token` from the dry run with the same rows.
3. Up to about 5,000 rows per call; split larger maps into batches and keep a running total.
4. **Confirm**, then call again with `dry_run: false`.

Use 301 (permanent) for migrations. Use 302 or 307 only if the user says the move is temporary.

## 4. Point the old domain at RedirHub

Redirects only work once the old domain's DNS points to RedirHub.

1. If the domain is not connected yet, `connect-host` it.
2. Call `check-host-dns` and tell the user exactly which record to add (CNAME or A + TXT, name and value) at their DNS provider. Do not guess records; use the ones the tool returns.
3. After they change DNS, `refresh-host` to re-check. HTTPS for the domain is issued automatically once DNS is correct; `get-host` shows its state.

Warn the user that changing DNS moves all traffic for that host to the redirects, so the new site must already be live.

## 5. Verify after launch

1. `count-links` with `handler: "migration"` (and `dns_correct: false`) to confirm every record exists and none is waiting on DNS.
2. Spot-check a few important old URLs with `get-link`.
3. After traffic starts, use `get-access-logs` (optionally `bot_free: true`) and `get-stats` to see which old URLs are being hit. Requests to old paths with no record mean a missing mapping: add them with `create-redirect` or another small `bulk-import`.
4. Suggest the user keep the redirects in place for at least a year, and update internal links and the sitemap on the new site to the new URLs.

## Rules

- Never write to the workspace without a dry run the user has seen. `bulk-import`, `bulk-update-links` and `bulk-delete-links` all dry-run by default; keep it that way until the user confirms.
- Never delete existing links during a migration unless the user explicitly asks; deletions are irreversible.
- Do not invent DNS records, URLs or counts. Report what the tools return.
- If a tool reports a plan or link limit, tell the user plainly and stop; do not split work to get around it.
