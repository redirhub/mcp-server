# RedirHub MCP Server

**Control every redirect from your AI assistant.** Create, update, test, and monitor URL redirects through a standardized protocol — compatible with Claude, Cursor, and any MCP client.

RedirHub is redirect infrastructure. This MCP server gives your AI agents direct access to that infrastructure: manage redirects and short links, update domains, invite team members — all without opening a dashboard.

## Endpoint

```
https://service.redirhub.com/mcp/v1
```

## Authentication

Generate a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) (**Settings → API Tokens**) and pass it as a Bearer token:

```
Authorization: Bearer rh_xxx...xxxx
```

The MCP server is available on **all plans**, including Free.

## Resources

Read workspace data via URI — append query params as `?key=value`.

| URI | Description |
|-----|------|
| `redirects://list` | List redirect records |
| `redirects://{id}` | Get a single redirect by hashid |
| `redirects://count` | Count total and paused redirects |
| `links://list` | List short links |
| `links://{id}` | Get a single short link by hashid |
| `hosts://list` | List custom domains |
| `hosts://{hostname}` | Get a domain by hostname |
| `workspace://current` | Current workspace info |
| `members://list` | List workspace members |
| `members://{user_id}` | Get a member by UUID |
| `account://me` | Current user profile |
| `plugins://catalog` | Available redirect plugins |
| `record-types://catalog` | Available redirect types and routing strategies |

**Filter params** (on `://list` endpoints): `filter[host]`, `filter[search]`, `filter[tags]`, `filter[dns_correct]`, `filter[created_after]`, `filter[created_before]`, `sort`, `per_page`, `cursor`

## Tools

### Record Management

| Tool | What It Does |
|------|------|
| `create-redirect-tool` | Create one or more redirect records |
| `create-link-tool` | Create a short link |
| `update-record-tool` | Update any record (redirect or short link) |
| `delete-record-tool` | Delete any record |

### Domain Management

| Tool | What It Does |
|------|------|
| `update-host-tool` | Update domain settings |
| `refresh-host-tool` | Refresh DNS status |
| `create-host-link-tool` | Enable domain for short links |
| `delete-host-link-tool` | Disable short links on a domain |

### Workspace & Members

| Tool | What It Does |
|------|------|
| `add-member-tool` | Invite a new member |
| `update-member-tool` | Update member role |
| `remove-member-tool` | Remove a member |
| `update-workspace-tool` | Update workspace settings |

### Bulk Operations

| Tool | What It Does |
|------|------|
| `bulk-update-records-tool` | Apply field changes across records (always use `dry_run: true` first) |
| `bulk-delete-records-tool` | Delete records by source URLs |
| `bulk-import-tool` | Import records from JSON |

## Quick Start

### 1. Get Your API Token

Sign up at [redirhub.com](https://redirhub.com) and create a Workspace API token from [dash.redirhub.com](https://dash.redirhub.com) **Settings → API Tokens**.

### 2. Configure Your MCP Client

Add to your client config — the endpoint accepts standard MCP HTTP transport:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://service.redirhub.com/mcp/v1",
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

> *"Import these 500 URLs from this JSON into my workspace."*

## Documentation

- [API Reference](https://dev.redirhub.com) — Full RedirHub API docs
- [dash.redirhub.com](https://dash.redirhub.com) — Web dashboard
- [MCP Specification](https://modelcontextprotocol.io) — Protocol docs

---

Built by [RedirHub](https://redirhub.com) — redirect infrastructure for teams that can't afford broken links.
