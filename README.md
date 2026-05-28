# RedirHub MCP Server

**Control every redirect from your AI assistant.** Create, update, test, and monitor URL redirects through a standardized protocol — compatible with Claude, Cursor, and any MCP client.

RedirHub is redirect infrastructure. This MCP server gives your AI agents direct access to that infrastructure: create rules, verify destinations, and audit traffic — all without opening a dashboard.

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

## What You Can Do

### Resources

Read your redirect infrastructure as structured data:

- **Workspace** — Account configuration
- **Member** — Team access
- **Host** — Domain settings per host
- **Link** — Individual redirect rules
- **Redirect** — Advanced redirect configurations
- **Account** — Billing details
- **Plugins** — Available integrations
- **RecordTypes** — Record type definitions
- **CountRedirects** — Redirect volume metrics
- **ListLinks / ListHosts / ListMembers / ListRedirects** — Paginated views

### Tools

| Tool | What It Does |
|------|------|
| CreateLink / UpdateLink / DeleteLink | Manage redirect rules |
| CreateRedirect / UpdateRedirect / DeleteRedirect | Manage advanced redirect configurations |
| CreateHost / UpdateHost / DeleteHost | Manage custom domains |
| CreateMember / UpdateMember / DeleteMember | Manage team access |
| CreateWorkspace / UpdateWorkspace | Manage workspaces |
| BulkImport / BulkDelete / BulkUpdateRecords | Operate on many records at once (supports `dry_run`) |
| DescribeResource / QueryResource / GetRecord / ExecuteBulkAction | Inspect schemas, query data, and run actions |

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

This config works for Claude Desktop, Cursor, and any MCP-compatible HTTP client.

### 3. Use It

Once connected, tell your AI agent what you need:

> *"Create a 301 redirect from `/old-blog` to `/blog` on my domain."*

> *"Show me analytics for all redirects on my marketing domain."*

> *"Import these 500 URLs from this CSV into a new host."*

## Documentation

- [API Reference](https://dev.redirhub.com) — Full RedirHub API docs
- [dash.redirhub.com](https://dash.redirhub.com) — Web dashboard
- [MCP Specification](https://modelcontextprotocol.io) — Protocol docs

---

Built by [RedirHub](https://redirhub.com) — redirect infrastructure for teams that can't afford broken links.
