# MCP Setup

Use the below installation instructions per MCP server.

## Azure Bicep

### Requirements

- Codex installed and authenticated
- .NET 10 SDK or later installed

```text
codex --version
dotnet --version
```

### CLI install

```text
codex mcp add bicep -- dnx -y Azure.Bicep.McpServer
```

### Config install (`config.toml`)

Edit your Codex config:

- macOS/Linux: `~/.codex/config.toml`
- Windows: `C:\Users\CODE\.codex\config.toml`

Add:

```toml
[mcp_servers.bicep]
command = "dnx"
args = ["Azure.Bicep.McpServer", "--yes"]
```

### Verify

```text
codex mcp list
```

In an active Codex session, you can also check `/mcp`.

## Microsoft Learn

### Requirements

- Codex installed and authenticated

```text
codex --version
```

### CLI install

```text
codex mcp add microsoft_learn --url https://learn.microsoft.com/api/mcp
```

### Config install (`config.toml`)

Edit your Codex config:

- macOS/Linux: `~/.codex/config.toml`
- Windows: `C:\Users\CODE\.codex\config.toml`

Add:

```toml
[mcp_servers.microsoft_learn]
url = "https://learn.microsoft.com/api/mcp"
```

### Verify

```text
codex mcp list
```

In an active Codex session, you can also check `/mcp`.
