# MCP Setup

Use the below installation instructions per MCP server.

## Azure Bicep

### Requirements

- Codex installed and authenticated
- .NET 10 SDK or later installed

```powershell
codex --version
dotnet --version
```

### CLI install

```powershell
codex mcp add bicep -- dnx -y Azure.Bicep.McpServer
```

### Config install (`config.toml`)

Edit:

`C:\Users\CODE\.codex\config.toml`

Add:

```toml
[mcp_servers.bicep]
command = "dnx"
args = ["Azure.Bicep.McpServer", "--yes"]
```

### Verify

```powershell
codex mcp list
```

In an active Codex session, you can also check `/mcp`.

## Microsoft Learn

### Requirements

- Codex installed and authenticated

```powershell
codex --version
```

### CLI install

```powershell
codex mcp add microsoft_learn --url https://learn.microsoft.com/api/mcp
```

### Config install (`config.toml`)

Edit:

`C:\Users\CODE\.codex\config.toml`

Add:

```toml
[mcp_servers.microsoft_learn]
url = "https://learn.microsoft.com/api/mcp"
```

### Verify

```powershell
codex mcp list
```

In an active Codex session, you can also check `/mcp`.
