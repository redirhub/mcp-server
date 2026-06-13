# RedirHub MCP Server

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/redirhub/mcp-server/pulls)
[![MCP Server](https://img.shields.io/badge/MCP-Server-v1.0-FF6B35.svg)](https://modelcontextprotocol.io)
[![Built for AI Agents](https://img.shields.io/badge/Built%20for-AI%20Agents-8B5CF6.svg)](https://redirhub.com)

**Control every redirect from your AI assistant.** Create, update, test, and monitor URL redirects through a standardized protocol — compatible with Claude, Cursor, and any MCP client.

RedirHub is redirect infrastructure. This MCP server gives your AI agents direct access to that infrastructure: manage redirects and short links, update domains, invite team members, query analytics — all without opening a dashboard.

## Features

- **AI-Native Redirect Management** — Create, update, and test URL redirects through natural language. No dashboard required.
- **Custom Short Links** — Generate branded short URLs with your own domains. Full alternative to Bitly.
- **DNS Verification** — Automatic DNS correctness checks so your redirects always resolve.
- **Analytics & Logs** — Query click statistics and raw access logs directly from your AI assistant.
- **Team Collaboration** — Multi-member workspace with role-based access control.
- **MCP Protocol** — Compatible with Claude, Cursor, Cline, and any MCP client.

## Endpoint

```
https://api.redirhub.com/mcp/v1
```

## Authentication

Generate a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) (**Settings → API Tokens**) and pass it as a Bearer token:

```
Authorization: Bearer ***
```

Available on **all plans**, including Free.

## Server Info

- **Name:** Redirect Infra Public API
- **Version:** 1.0.1
- **Transport:** Streamable HTTP (JSON-RPC 2.0)

## Data Model

Users belong to **workspaces** (organizations). Workspaces contain **custom domains** (Hosts) and **records** (Records, including redirects and short links).

## Resources

Read workspace data via URI — append query params as `?key=value`.

### Redirect Records

| URI | Description | Filter Params |
|-----|------|------|
| `redirects://list` | List redirect records | `filter[host]`, `filter[search]`, `filter[tags]`, `filter[dns_correct]`, `filter[created_after]`, `filter[created_before]`, `sort`, `per_page`, `cursor` |
| `redirects://{id}` | Get a single redirect by hashid | — |
| `redirects://count` | Count total and paused redirects | — |

### Short Links

| URI | Description | Filter Params |
|-----|------|------|
| `links://list` | List short links | Same as `redirects://list` |
| `links://{id}` | Get a single short link by hashid | — |

### Domains

| URI | Description | Filter Params |
|-----|------|------|
| `hosts://list` | List custom domains | `filter[search]`, `filter[short_url]`, `sort`, `per_page`, `cursor` |
| `hosts://{hostname}` | Get a domain by hostname | — |

### Workspace & Members

| URI | Description |
|-----|------|
| `workspace://current` | Current workspace info |
| `members://list` | List workspace members |
| `members://{user_id}` | Get a member by UUID |

### Account

| URI | Description |
|-----|------|
| `account://me` | Current user profile |

### Catalogs

| URI | Description |
|-----|------|
| `plugins://catalog` | Available redirect plugins |
| `record-types://catalog` | Available redirect types and routing strategies |

## Tools

### Record Management

| Tool | What It Does |
|------|------|
| `create-redirect-tool` | Create a redirect record |
| `create-link-tool` | Create a short link (requires host + destination) |
| `update-record-tool` | Update any record (redirect or short link) by hashid |
| `delete-record-tool` | Delete any record (redirect or short link) by hashid |

### Domain Management

| Tool | What It Does |
|------|------|
| `connect-host-tool` | Connect a domain to your workspace. Supports root (`example.com`), subdomain (`sub.example.com`), and wildcard (`*.example.com`). Optionally enable or disable short URLs. Returns DNS configuration instructions. |
| `update-host-tool` | Update domain settings (currently HTTPS toggle only) |
| `refresh-host-tool` | Refresh DNS status for a domain |

### Workspace & Members

| Tool | What It Does |
|------|------|
| `add-member-tool` | Invite a new member |
| `update-member-tool` | Update member role |
| `remove-member-tool` | Remove a member |
| `update-workspace-tool` | Update workspace settings |

### Account

| Tool | What It Does |
|------|------|
| `update-account-tool` | Update user profile |

### 📊 Statistics (read-only)

| Tool | What It Does |
|------|------|
| `get-stats-tool` | Get analytics (click) data. Set `file`/`files` for per-link stats (totals, daily trend, breakdowns by country/city/browser/device/referrer/proto); omit for org-level stats (total clicks, unique visitors, active/total link counts, breakdowns by file/handler). Supports `time_range` (7d/30d/90d/this_month/last_month/lifetime) or custom `date_from`+`date_to`. Optional `handler` and `limit`. |
| `get-access-logs-tool` | Get raw HTTP request logs. Returns individual visit records (timestamp, IP, user agent, country, browser, referrer, etc.). Optional filters: `file`, `time_range`/`date_from`+`date_to`, `country`, `handler`, `browser`, `device`, `referrer`, `search` (IP or UA). Supports cursor-based pagination. |

### Bulk Operations

| Tool | What It Does |
|------|------|
| `bulk-update-records-tool` | Apply field changes across records |
| `bulk-delete-records-tool` | Delete records by `source_urls[]` (array of source URLs) |
| `bulk-import-tool` | Import records from JSON `rows[]` |

**Bulk import format:** Each row: `{url, destination, type?, handler?, title?, description?, tags?, destinations?}`. `handler` is `"redirect"` or `"short-url"`. Supports `mode=create|upsert` and `dry_run`.

### ⚠️ Bulk Operation Safety

For `bulk-update-records-tool`, `bulk-delete-records-tool`, and `bulk-import-tool`:

1. ALWAYS invoke first with `dry_run: true` to preview the affected count.
2. Display the affected count to the user.
3. Only re-invoke with `dry_run: false` after explicit user confirmation.

## Quick Start

### 1. Get Your API Token

Sign up at [redirhub.com](https://redirhub.com) and create a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) **Settings → API Tokens**.

### 2. Configure Your MCP Client

Add to your client config — the endpoint accepts standard MCP HTTP transport:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://api.redirhub.com/mcp/v1",
      "headers": {
        "Authorization": "Bearer rh_YOUR_API_TOKEN"
      }
    }
  }
}
```

Works with Claude Desktop, Cursor, and any MCP-compatible HTTP client.

### 3. Use It

Once connected, tell your AI agent what you need:

> *"Create a 301 redirect from `/old-blog` to `/blog` on my domain."*

> *"List all short links on my marketing domain."*

> *"Show me click stats for the past 30 days."*

> *"Import these 500 URLs from this JSON into my workspace."*

## Documentation

- [API Reference](https://dev.redirhub.com) — Full RedirHub API docs
- [dash.redirhub.com](https://dash.redirhub.com) — Web dashboard
- [MCP Specification](https://modelcontextprotocol.io) — Protocol docs

---

Built by [RedirHub](https://redirhub.com) — redirect infrastructure for teams that can't afford broken links.
