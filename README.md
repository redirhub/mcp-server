# RedirHub MCP Server

MCP (Model Context Protocol) server for managing URL redirects via AI agents. Connect your AI assistants directly to RedirHub's powerful redirect management platform — create, update, test, and monitor URL redirects through a standardized protocol that works with Claude, Cursor, and any MCP-compatible client.

## Endpoint

```
https://api.redirhub.com/mcp/v1
```

## Authentication

All requests require a **Bearer token** — your RedirHub API key. You can generate an API key from the [RedirHub Dashboard](https://app.redirhub.com) under **Settings → API Keys**.

```
Authorization: Bearer rh_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Plans & Availability

The MCP endpoint is available on **all RedirHub plans**, including the **Free** tier. No additional cost — it's included with your RedirHub account.

| Plan | MCP Access | Rate Limits |
|------|-----------|-------------|
| Free | ✅ | Generous free-tier limits |
| Pro | ✅ | Higher throughput |
| Business | ✅ | Enterprise-grade limits |

[View all plans →](https://redirhub.com/pricing)

## Features

### Resources (15+)

Access your RedirHub data as structured resources that AI agents can read and navigate:

- **Redirects** — List, view, and filter all your URL redirects
- **Hosts** — Manage your custom domain configurations
- **Domains** — View and manage domain settings
- **Analytics** — Access redirect traffic and performance data
- **Settings** — Read account and workspace settings

### Tools (17+)

Full CRUD operations available through MCP tools that AI agents can invoke:

- `create_redirect` — Create a new URL redirect
- `update_redirect` — Modify an existing redirect
- `delete_redirect` — Remove a redirect
- `list_redirects` — Query redirects with filters
- `get_redirect` — Fetch a single redirect by ID
- `test_redirect` — Verify a redirect resolves correctly
- `bulk_create_redirects` — Import multiple redirects at once
- `create_host` / `update_host` / `delete_host` — Host management
- `verify_dns` — Check DNS propagation for custom domains
- `get_analytics` — Retrieve redirect hit counts and stats
- ...and more

## Quick Start

### 1. Get your API Key

Sign up at [redirhub.com](https://redirhub.com) and grab your API key from the [dashboard](https://app.redirhub.com/settings/api-keys).

### 2. Configure your MCP client

Add the RedirHub MCP server to your MCP client configuration:

#### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://api.redirhub.com/mcp/v1",
      "headers": {
        "Authorization": "Bearer rh_YOUR_API_KEY"
      }
    }
  }
}
```

#### Cursor

Add to your Cursor MCP configuration (`.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://api.redirhub.com/mcp/v1",
      "headers": {
        "Authorization": "Bearer rh_YOUR_API_KEY"
      }
    }
  }
}
```

#### Generic MCP Client

Any MCP-compatible HTTP client can connect:

```json
{
  "mcpServers": {
    "redirhub": {
      "url": "https://api.redirhub.com/mcp/v1",
      "headers": {
        "Authorization": "Bearer rh_YOUR_API_KEY"
      }
    }
  }
}
```

### 3. Start using it

Once connected, you can ask your AI agent to manage redirects:

> "Create a redirect from `/old-blog` to `/blog` on my domain example.com"

> "List all redirects on my marketing site"

> "Test if the redirect for `/promo-2024` is working correctly"

## Example Tool Usage

Here's what a typical interaction looks like through an AI agent:

```
User: Create a 301 redirect from /summer-sale to /promotions/summer-2026
      on my domain shop.example.com

Agent: [calls create_redirect tool]
       ✓ Redirect created
         • Source: /summer-sale
         • Target: /promotions/summer-2026
         • Type: 301 (Permanent)
         • Host: shop.example.com
         • ID: red_abc123
```

The agent can also chain operations:

```
User: Migrate all /blog/* paths to /articles/* with 301 redirects

Agent: [Reads existing redirects → Bulk creates new ones → Tests a sample]
       ✓ 47 redirects created
       ✓ All tests passed
```

## Documentation

Full API documentation, guides, and reference:

- **[RedirHub Docs](https://docs.redirhub.com)** — Complete platform documentation
- **[MCP Specification](https://modelcontextprotocol.io)** — Model Context Protocol specification
- **[RedirHub Dashboard](https://app.redirhub.com)** — Manage redirects via the web UI

## Links

- 🌐 [redirhub.com](https://redirhub.com) — Website
- 📖 [docs.redirhub.com](https://docs.redirhub.com) — Documentation
- 🔧 [app.redirhub.com](https://app.redirhub.com) — Dashboard
- 📦 [github.com/redirhub/mcp-server](https://github.com/redirhub/mcp-server) — This repository

## License

MIT License — see [LICENSE](LICENSE) for details.

---

Built with ❤️ by [RedirHub](https://redirhub.com) — Simple, powerful URL redirect management.
