# RedirHub MCP Server

MCP (Model Context Protocol) server for managing URL redirects via AI agents. Connect your AI assistants directly to RedirHub's redirect management platform — create, update, test, and monitor URL redirects through a standardized protocol compatible with Claude, Cursor, and any MCP-compatible client.

## Endpoint

```
https://service.redirhub.com/mcp/v1
```

## Authentication

All requests require a **Bearer token** — your RedirHub Workspace API token. You can generate one from the [RedirHub Dashboard](https://dash.redirhub.com) under **Settings → API Tokens**.

```
Authorization: Bearer rh_xxx...xxxx
```

## Plans & Availability

The MCP server is available on **all RedirHub plans**, including the **Free** tier.

| Plan | MCP Access |
|------|-----------|
| Free  | ✅ |
| Basic | ✅ |
| Pro   | ✅ |
| Enterprise | ✅ |

[View all plans →](https://redirhub.com/pricing)

## Server Info

- **Name**: Redirect Infra Public API v1.0.0
- **Transport**: Streamable HTTP (JSON-RPC 2.0)

## Resources (15+)

Access your RedirHub data as structured resources:

| Resource | Description |
|----------|-------------|
| Workspace | Account and workspace settings |
| Member | Team members and permissions |
| Host | Custom domain configurations |
| Link (redirect) | Individual redirect rules |
| Redirect | Advanced redirect configurations |
| Account | Billing and account details |
| Plugins | Available plugins and integrations |
| RecordTypes | Types of redirect records |
| CountRedirects | Redirect count metrics |
| ListLinks | Paginated redirect listings |
| ListHosts | Paginated host listings |
| ListMembers | Paginated member listings |
| ListRedirects | Paginated redirect configurations |

## Tools (17+)

### CRUD Operations

| Tool | Description |
|------|-------------|
| CreateLink | Create a new redirect rule |
| UpdateLink | Modify an existing redirect |
| DeleteLink | Remove a redirect |
| CreateRedirect | Create advanced redirect configuration |
| UpdateRedirect | Update redirect configuration |
| DeleteRedirect | Remove redirect configuration |
| CreateHost | Add a new custom domain |
| UpdateHost | Update domain settings |
| DeleteHost | Remove a domain |
| CreateMember | Invite a team member |
| UpdateMember | Modify member permissions |
| DeleteMember | Remove a team member |
| CreateWorkspace | Create a new workspace |
| UpdateWorkspace | Update workspace settings |

### Bulk Operations (with Dry-Run)

| Tool | Description |
|------|-------------|
| BulkImport | Import multiple records at once |
| BulkDelete | Bulk delete records |
| BulkUpdateRecords | Bulk update records (supports `dry_run` parameter for safe preview) |

### Admin / Query Tools

| Tool | Description |
|------|-------------|
| DescribeResource | View resource schema and available fields |
| QueryResource | Query resources with filters, pagination, and sorting |
| GetRecord | Fetch a single record by ID |
| ExecuteBulkAction | Execute a bulk action on filtered records |

## Quick Start

### 1. Get Your API Token

Sign up at [redirhub.com](https://redirhub.com) and create a Workspace API token from the [dashboard](https://dash.redirhub.com) under **Settings → API Tokens**.

### 2. Configure Your MCP Client

Add the RedirHub MCP server to your client configuration:

#### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

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

#### Cursor

Add to `.cursor/mcp.json`:

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

#### Generic MCP HTTP Client

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

### 3. Start Using It

Once connected, you can ask your AI agent to manage redirects:

> "Create a redirect from `/old-blog` to `/blog` on my domain example.com"

> "List all redirects on my marketing site"

> "Show me the analytics for redirect `red_abc123`"

## Documentation

- **[API Documentation](https://dev.redirhub.com)** — Complete RedirHub API reference
- **[RedirHub Dashboard](https://dash.redirhub.com)** — Manage redirects via the web UI
- **[MCP Specification](https://modelcontextprotocol.io)** — Model Context Protocol specification

## Links

- 🌐 [redirhub.com](https://redirhub.com) — Website
- 📖 [dev.redirhub.com](https://dev.redirhub.com) — API Documentation
- 🔧 [dash.redirhub.com](https://dash.redirhub.com) — Dashboard
- 📦 [github.com/redirhub/mcp-server](https://github.com/redirhub/mcp-server) — This repository

## License

MIT License — see [LICENSE](LICENSE) for details.

---

Built with ❤️ by [RedirHub](https://redirhub.com) — Simple, powerful URL redirect management.
