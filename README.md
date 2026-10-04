# RedirHub MCP Server

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/redirhub/mcp-server/pulls)
[![MCP Server](https://img.shields.io/badge/MCP-Server-v1.2-FF6B35.svg)](https://modelcontextprotocol.io)
[![Built for AI Agents](https://img.shields.io/badge/Built%20for-AI%20Agents-8B5CF6.svg)](https://redirhub.com)

**Control every link from your AI assistant.** Create branded links, dynamic QR codes, domain redirects and whole website migrations, then manage, audit and measure them through a standardized protocol, compatible with Claude, ChatGPT, Cursor and any MCP client.

RedirHub is redirect infrastructure. This MCP server gives your AI agents direct access to that infrastructure: create and manage links, connect domains, invite team members and query analytics, all without opening a dashboard.

## Features

- **One model for every link**: branded links, dynamic QR codes, domain redirects and website migrations are created by intent and managed as one kind of object, as in the dashboard.
- **QR codes your agent can hand over**: `create-qr-code` and `get-qr-code` return the QR code image itself, drawn exactly as the dashboard draws it.
- **Safe bulk changes**: bulk tools preview by default and only apply changes with a confirmation token from that preview.
- **Same rules as the dashboard**: links created or updated here go through the same validation, plan features and limits as the dashboard and the REST API.
- **Analytics & logs**: query click statistics, raw access logs and each link's change history.
- **Team collaboration**: multi-member workspaces with role-based access control.
- **Sign in, no token to copy**: assistants connect with OAuth. You sign in to RedirHub, pick the workspace and choose what the assistant may do; disconnect it any time.
- **MCP protocol**: works with Claude, ChatGPT, Cursor, Cline and any MCP client that calls tools.

## Endpoint

```
https://mcp.redirhub.com/mcp/v1
```

## Authentication

### Sign in with OAuth (recommended)

Add the endpoint to your assistant and it sends you to RedirHub to sign in. There is no token to copy:

1. Sign in to RedirHub (or switch account).
2. Pick the **workspace** the assistant works in. Each connection works in one workspace.
3. Choose what it may do (below) and select **Allow access**.

The assistant is then listed in **Account → AI assistants** ([account.redirhub.com/mcp](https://account.redirhub.com/mcp)), where you, or a workspace manager, can disconnect it. Disconnecting revokes its access at once; the links it made stay.

| Permission | Scope | Tools | Who can grant it |
|-----|-----|-----|-----|
| See your links, domains and click stats | `links:read` | every read tool: `list-links`, `get-link`, `count-links`, `get-link-history`, `get-qr-code`, `get-link-options`, `list-hosts`, `get-host`, `check-host-dns`, `get-workspace`, `list-members`, `get-account`, `get-stats`, `get-access-logs` | any member (always granted) |
| Create and edit links | `links:write` | `create-branded-link`, `create-qr-code`, `create-redirect`, `update-link`, `bulk-update-links`, `bulk-import` | editor and up (on by default) |
| Delete links | `links:delete` | `delete-link`, `bulk-delete-links` | editor and up |
| Add and change domains | `domains:write` | `connect-host`, `update-host`, `refresh-host` | editor and up |
| Manage members and workspace settings | `workspace:admin` | `update-workspace`, `add-member`, `update-member`, `remove-member`, `update-account` | manager and owner |

The assistant only sees the tools it was granted. Calling another one returns an error naming the permission it needs; to grant more, disconnect the assistant and connect it again.

For client developers: the server follows the [MCP authorization spec](https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization). A request without a token gets `401` with a `WWW-Authenticate` header pointing at the protected resource metadata (`https://mcp.redirhub.com/.well-known/oauth-protected-resource/mcp/v1`). The authorization server is `https://account.redirhub.com` (metadata at `/.well-known/oauth-authorization-server`). It supports:

- dynamic client registration (`/oauth/register`);
- the authorization code flow with PKCE (`S256`);
- refresh tokens.

Access tokens last an hour and refresh tokens 30 days.

### API token

For scripts and clients that can't sign in, generate a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) (**Settings → API Tokens**) and pass it as a Bearer token:

```
Authorization: Bearer ***
```

An API token has every tool. It acts in the workspace it was created for, within your role: changing links and domains needs the **editor** role; workspace settings and members need the **manager** role.

Both ways are available on **all plans**, including Free.

## Server Info

- **Name:** Redirect Infra Public API
- **Version:** 1.2.0
- **Transport:** Streamable HTTP (JSON-RPC 2.0)

## Data Model

Users belong to **workspaces** (organizations). A workspace has **custom domains** (hosts) and **links**.

Links are **created from four intents** but **managed as one kind of object**:

| Intent | Tool | What it is |
|-----|------|------|
| Branded link | `create-branded-link` | A short URL on your own short-link domain, e.g. `go.acme.co/spring` |
| Dynamic QR code | `create-qr-code` | A branded link meant for print; its destination can change after printing |
| Domain redirect | `create-redirect` | A domain, subdomain or path sent to a destination, e.g. `old.acme.co` → `acme.com` |
| Website migration | `bulk-import` with `handler: "migration"` | Many old URLs mapped to new ones at once |

Every link has an `id` (e.g. `link_7bXmR4`) that the `get-link`, `update-link`, `delete-link`, `get-qr-code` and `get-link-history` tools take. Domains are addressed by hostname, members by `id` (e.g. `user_zwbJjgb8`).

## Tools

### Links: read

| Tool | What It Does |
|------|------|
| `list-links` | List links, newest first. Filters: `ids`, `handler` (`redirect`, `migration`, `short-url`, `qr`), `host`, `search`, `tags`, `status` (`active`/`paused`), `dns_correct`, `created_after`, `created_before`. Paginate with `per_page` (max 100) and `cursor`. |
| `get-link` | One link by `id`: destinations, redirect type, plugins, UTM parameters, QR style and tags. |
| `count-links` | Counts for the same filters: `total`, `paused`, `dns_issue` and `no_clicks` (no click in the last four weeks). |
| `get-link-history` | A link's changes, newest first: what changed (destination, UTM, type, status), who changed it and how. Needs the audit log feature (Pro plans and up); without it only the count is returned. |
| `get-qr-code` | A link's QR code as a PNG image, in its saved style, with the workspace logo when the style asks for it. |
| `get-link-options` | The accepted values: redirect types, destination routing strategies and plugins, with the plan feature each needs. |

### Links: create

| Tool | What It Does |
|------|------|
| `create-branded-link` | `host` (a short-link domain) and `destination` required; optional `alias` (generated when omitted), `title`, `description`, `utm`, `tags`, `status`. |
| `create-qr-code` | Same arguments as `create-branded-link`. Returns the link **and the QR code image** in the default style; the style can be customized in the dashboard. |
| `create-redirect` | `url` (the source: domain, subdomain or path) required; optional `destination`, `destinations` + `destination_routing`, `type` (`301`, `302`, `307`, `308`, `frame`, `txt`), `forward_path`, `forward_query`, `plugins`, `utm`, `title`, `description`, `tags`, `status`. |

Use `list-hosts` with `short_links_enabled: true` to find the domains branded links and QR codes can use.

### Links: manage

| Tool | What It Does |
|------|------|
| `update-link` | Update a link by `id`. Only the fields given change; the source URL and the kind of link never do. |
| `delete-link` | Delete a link by `id`, with its change history. Irreversible. |
| `bulk-update-links` | Apply the same changes to many links. Select them with the `list-links` filters (except `tags` and `status`, which it sets), or `all_links: true` for every link. |
| `bulk-delete-links` | Delete links by `source_urls[]`, e.g. `["acme.co/old-page"]`. |
| `bulk-import` | Import up to ~5,000 links per call from `rows[]`. Each row: `{url, destination?, handler?, type?, title?, description?, tags?, destinations?, destination_routing?, utm?}`; `handler` is `redirect` (default), `migration` or `short-url`. `mode` is `create` (default; existing source URLs are skipped) or `upsert` (they are replaced). Counts against the plan's link limit. |

### ⚠️ Bulk operation safety

`bulk-update-links`, `bulk-delete-links` and `bulk-import` **only preview unless called with `dry_run: false`**:

1. Call without `dry_run`. The preview returns the affected count, a sample of the affected URLs and, for changes and deletions, a `confirmation_token`.
2. Show the count to the user.
3. Only after the user confirms, call again with **the same arguments**, `dry_run: false` and the `confirmation_token`.

The server enforces this: `bulk-update-links`, `bulk-delete-links` and `bulk-import` in `upsert` mode refuse to apply changes without a token issued for exactly the same arguments, by the same user, in the same workspace, within the last one to two hours.

### Domains

| Tool | What It Does |
|------|------|
| `list-hosts` | List custom domains with their DNS, HTTPS and short-link status. Filters: `search`, `short_links_enabled`, `shared` (also list the platform's shared domains). |
| `get-host` | One domain by hostname, with the DNS records it needs. |
| `check-host-dns` | Look the domain's DNS up live and compare it with the records each setup path (CNAME, IP+TXT, NS delegation) needs, next to what the last scheduled check saw. Use it to find out why a domain doesn't work yet. Nothing is saved. |
| `connect-host` | Connect a root (`acme.com`), sub (`go.acme.com`) or wildcard (`*.acme.com`) domain; returns the DNS records to add. Optional `short_links_enabled`, `https_requested`. |
| `update-host` | Toggle HTTPS and short links on a domain. |
| `refresh-host` | Re-check a domain's DNS now. |

### Workspace & members

| Tool | What It Does |
|------|------|
| `get-workspace` | The current workspace: plan, limits, usage and settings. |
| `update-workspace` | Update a setting: `name`, `country`, `email`, `billing_extra`, `email_summary`, `email_host_status`, `email_manager`. |
| `list-members` | Members with their role (`viewer`, `editor`, `manager`). |
| `add-member` | Invite people by email: `invites: [{email, role?}]`. |
| `update-member` | Change a member's role. |
| `remove-member` | Remove a member. |

### Account

| Tool | What It Does |
|------|------|
| `get-account` | The signed-in user's profile. |
| `update-account` | Update a profile setting: `name`, `language`, `currency`, `timezone`, `current_workspace`, `login_workspace`, `country`, `phone`, `im`. |

### 📊 Statistics

| Tool | What It Does |
|------|------|
| `get-stats` | Click analytics. Set `file`/`files` for per-link stats (totals, daily trend, breakdowns by country, city, browser, device, referrer, protocol); omit them for workspace stats (total clicks, unique visitors, active/total link counts, breakdowns by link and kind). `time_range` is `7d`, `30d`, `90d`, `180d`, `this_month` or `last_month`, or use `date_from` + `date_to`. Clicks reach back 90 days (180 on plans with more analytics history); breakdowns cover the last 14 days (Enterprise: no limit). |
| `get-access-logs` | Raw visits (time, IP, user agent, country, browser, referrer, ...). Filters: `file`, `date_from`/`date_to`, `country`, `handler`, `browser`, `device`, `referrer`, `search` (IP or user agent), `bot_free`. Covers the last 14 days (Enterprise: no limit). Cursor pagination. |

## QR codes

`create-qr-code` and `get-qr-code` return the code as a 512 px PNG, drawn exactly as the dashboard draws it: same modules, colors, margin, workspace logo and readable link underneath. The code encodes the link with `?utm_source=qr`, so scans are counted separately from clicks.

For print files, the REST API serves the same code as SVG or PNG (512, 1024 or 2048 px wide):

```
GET https://api.redirhub.com/v1/links/{id}/qr              # SVG
GET https://api.redirhub.com/v1/links/{id}/qr?format=png&width=2048
```

## Resources

Clients that attach MCP resources can also read the same data as resources (append query params as `?key=value`): `redirects://list`, `redirects://link_{id}`, `redirects://count`, `links://list`, `links://link_{id}`, `hosts://list`, `hosts://{hostname}`, `workspace://current`, `members://list`, `members://{user_id}`, `account://me`, `plugins://catalog` and `record-types://catalog`.

Most clients only let the model call tools, so prefer the tools above; they cover everything the resources do.

## Renamed tools

Version 1.1 dropped the `-tool` suffix and named the record tools after links. **The old names keep working**, so existing setups don't break, but new prompts and integrations should use the new ones:

| Old name | New name |
|------|------|
| `create-redirect-tool` | `create-redirect` |
| `create-link-tool` | `create-branded-link` |
| `update-record-tool` | `update-link` |
| `delete-record-tool` | `delete-link` |
| `bulk-update-records-tool` | `bulk-update-links` |
| `bulk-delete-records-tool` | `bulk-delete-links` |
| `bulk-import-tool` | `bulk-import` |
| `connect-host-tool`, `update-host-tool`, `refresh-host-tool` | `connect-host`, `update-host`, `refresh-host` |
| `add-member-tool`, `update-member-tool`, `remove-member-tool` | `add-member`, `update-member`, `remove-member` |
| `update-workspace-tool`, `update-account-tool` | `update-workspace`, `update-account` |
| `get-stats-tool`, `get-access-logs-tool` | `get-stats`, `get-access-logs` |

Other changes in 1.1:

- **Create tools return the link.** `create-redirect` used to wrap it in `{created, record}`.
- **Bulk tools preview by default.** They used to apply changes unless told otherwise.
- **`bulk-update-links` needs a filter or `all_links: true`.** It used to change every record in the workspace.

## Quick Start

### 1. Add the server to your assistant

**Claude** (claude.ai, Claude Desktop): **Settings → Connectors → Add custom connector**, name it `RedirHub` and paste `https://mcp.redirhub.com/mcp/v1`.

**ChatGPT**: **Settings → Apps & Connectors**, add a custom connector with the same URL.

**Cursor**: **Settings → MCP → Add new MCP server**, or in `mcp.json`:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://mcp.redirhub.com/mcp/v1"
    }
  }
}
```

**Any other MCP client**: add a remote (Streamable HTTP) server with the same URL. To try it from a terminal:

```bash
npx @modelcontextprotocol/inspector --transport http --server-url https://mcp.redirhub.com/mcp/v1
```

### 2. Sign in and choose what it can do

Your assistant opens RedirHub: sign in, pick a workspace and the permissions, and select **Allow access**. You're sent back to the assistant, connected.

<details>
<summary>Using an API token instead</summary>

Create a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) **Settings → API Tokens** and send it as a header:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://mcp.redirhub.com/mcp/v1",
      "headers": {
        "Authorization": "Bearer rh_YOUR_API_TOKEN"
      }
    }
  }
}
```

</details>

### 3. Use it

Once connected, tell your AI agent what you need:

> *"Create a QR code for our menu on go.acme.co that points to acme.com/menu, and show it to me."*

> *"Redirect old.acme.co to acme.com with a 301, keeping the path."*

> *"Migrate these 500 URLs from our old site to the new one."*

> *"How many links on go.acme.co had no clicks in the last four weeks? Pause every link on that domain."*

> *"Who changed the destination of go.acme.co/spring, and when?"*

## Documentation

- [API Reference](https://dev.redirhub.com): full RedirHub API docs
- [dash.redirhub.com](https://dash.redirhub.com): web dashboard
- [MCP Specification](https://modelcontextprotocol.io): protocol docs

---

Built by [RedirHub](https://redirhub.com): redirect infrastructure for teams that can't afford broken links.
