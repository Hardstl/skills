# Skill Documentation: bicep-avm-code

## Skill Overview

`bicep-avm-code` is the implementation skill for Azure Bicep templates. It is used to author or refactor templates with an AVM-first posture, then remediate issues until the code is deployment-ready.

Use it when you already know what solution to build and need clean, production-grade infrastructure code. Do not use it for architecture discovery or validation-only review.

This solution is AVM all the way: it should not rely on local module files or heavy parameterazation. Use direct `br/public:avm/...` modules and keep inputs limited to essential runtime and operational values.

## Inputs and Preconditions

Provide the design brief (or equivalent task context). Also provide:

- Project name (used for naming resources)
- Environment such as `dev`, `test`, `qa`, or `prod` (used for naming resources)

Before coding, confirm tools are available:

- `bicep --version`
- `mcp__bicep__list_avm_metadata`
- `mcp__bicep__get_bicep_best_practices`
- `mcp__bicep__get_bicep_file_diagnostics`
- `bicep build`
- `bicep lint`

## Workflow

1. Resolve required services and pinned AVM modules from one metadata snapshot.
2. Author with direct `br/public:avm/...` module references and apply producer-owned capabilities where supported.
3. Apply production guardrails: managed identity by default, secure defaults, required tags, and private networking posture when requested.
4. Run diagnostics, `bicep build`, `bicep lint`, and validation (`bicep-avm-validate`).
5. If blockers appear, remediate and re-validate. Stop after two remediation passes and report remaining blockers clearly.

## Outputs and Handoff

The expected output is updated, deployable Bicep code plus a short implementation summary.

Include these handoff details:

- AVM module paths and pinned versions used
- Exceptions used (and why), if any
- Validation/remediation status and any unresolved blockers

## Prompt Guide

Use direct prompts that include scope, services, security intent, and naming inputs.

Simple prompts:

- "Use `$bicep-avm-code` to implement a prod VNet + Storage + Key Vault solution. Project name is `contoso-payments`, environment is `prod`, private access only. For the VNet use address space 10.200.0.0/24."
- "Refactor this Bicep to AVM-first modules and remove wrapper modules. Keep behavior equivalent. Project `fabrikam-data`, environment `qa`."

Advanced prompt:

```markdown
Use `$bicep-avm-code` to author a full production Azure solution using AVM-only modules.

Context:
- Project name: contoso-payments
- Environment: prod
- Location: westeurope
- Intent: private-only connectivity; disable public access where supported
- Scope: resource group deployment

Implement:
1) Networking
   - VNet CIDR: 10.40.0.0/24
   - Subnets:
     - snet-app: 10.40.0.0/26
     - snet-pe: 10.40.0.64/26
     - snet-data: 10.40.0.128/26
   - Associate NSGs to all subnets
   - Do not deploy private DNS zones, it's centrally managed via policies
2) Observability
   - Log Analytics Workspace SKU: PerGB2018
   - Application Insights linked to workspace
3) Key Vault
   - RBAC enabled
   - Private endpoint
   - No public access
4) Storage Account
   - StorageV2 and LRS
   - Private endpoint
   - No public access
5) Service Bus Namespace
   - Premium
6) SQL
   - SQL Server + one database (serverless)
   - Private endpoint
   - No public access
7) Compute/App
   - Function App (powershell, flex consumption)
   - VNet integration to snet-app
   - Private endpoint enabled
```
