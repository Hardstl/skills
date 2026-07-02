# Skill Documentation: bicep-avm-code

## Skill Overview

`bicep-avm-code` is an example-led authoring skill for Azure Bicep templates using Azure Verified Modules (AVM). It authors or refactors Bicep code by reading a compact authoring contract, checking anti-patterns and capability ownership, and matching the closest golden Bicep reference.

Use it when agents need canonical examples to anchor direct module usage, low parameter surface area, producer-owned capabilities, private-by-default posture, environment parameter files, and executable checks. Do not use it for broad architecture discovery or validation-only review.

This solution is AVM all the way: it should not rely on local module files or heavy parameterization. Use direct `br/public:avm/...` modules and keep inputs limited to essential runtime, secret, environment, and operational values.

## Inputs and Preconditions

Provide the design brief or existing Bicep to refactor. Include:

- Project name
- Environment such as `dev`, `test`, `qa`, or `prod`
- Location
- Deployment scope and requested services
- Private/public exposure intent

Before coding, confirm tools are available:

- `bicep --version`
- `mcp__bicep__list_avm_metadata`
- `mcp__bicep__get_bicep_file_diagnostics`
- `bicep build`
- `bicep lint`

## Workflow

1. Read `references/authoring-contract.md`, `references/anti-patterns.md`, `references/capability-discovery.md`, and the closest golden Bicep example.
2. Resolve required inputs from context, and ask concise questions before authoring when `projectName`, `environment`, location, scope, services, or exposure intent are missing.
3. Resolve required services and pinned AVM modules from one metadata snapshot.
4. Author or refactor with direct `br/public:avm/...` module references and producer-owned capabilities discovered from selected module documentation.
5. Evaluate whether `main.<environment>.bicepparam` files can be generated from known values. Do not create placeholder parameter files.
6. Run diagnostics, `bicep build`, `bicep lint`, `bicep build <params-file>.bicepparam` for generated parameter files, and `scripts/check-avm-authoring.sh`.
7. Remediate blockers and re-run checks. Stop after two remediation passes and report remaining blockers clearly.

## Outputs and Handoff

- Files changed
- Environment parameter files generated, or omitted with missing values per environment
- AVM module paths and pinned versions used
- Diagnostics/build/lint/parameter-build/checker status
- Exceptions used and why
- Unresolved blockers, if any

## Prompt Guide

Use direct prompts that include scope, services, security intent, and naming inputs.

Simple prompts:

- "Use `$bicep-avm-code` to implement a private prod VNet + Storage + Key Vault + Function App solution. Project name is `contoso-payments`, environment is `prod`, location is `westeurope`."
- "Use `$bicep-avm-code` to refactor this Bicep to direct AVM modules. Preserve behavior, remove local wrappers, and match the golden example style."

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

Generate `main.dev.bicepparam`, `main.test.bicepparam`, and `main.prod.bicepparam` only when all required values are known. Run diagnostics, build, lint, parameter builds, and `scripts/check-avm-authoring.sh`.
```
