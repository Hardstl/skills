---
name: bicep-avm-code
description: Author or refactor Azure Bicep using Azure Verified Modules (AVM) from canonical reference examples. Use when Codex needs to create production-ready AVM-first Bicep, convert native or wrapper-heavy Bicep into direct AVM module usage, or enforce a compact example-led AVM authoring style with diagnostics, build, lint, parameter builds, and posture checks. Do not use for validation-only review or broad architecture discovery.
---

# Bicep AVM Code

Author Azure Bicep by copying the shape of the golden examples, not by inventing a new template architecture. Treat this skill as example-led authoring with executable checks.

## Required reading

Before authoring or refactoring, read these files:

1. `references/authoring-contract.md`
2. `references/anti-patterns.md`
3. `references/capability-discovery.md`
4. The closest matching golden Bicep file:
   - `references/golden-private-webapp-platform.bicep` for private Linux Web App plus Function App, VNet integration, hardened Storage, Key Vault, and managed identity patterns
   - `references/golden-brownfield-private-workload.bicep` for private workloads deployed into existing shared subnets and monitoring resources
   - `references/golden-container-platform.bicep` for private Azure Container Apps workloads with ACR, managed identity, Key Vault, and observability patterns
   - `references/golden-data-platform.bicep` for SQL, Storage, Key Vault, and Service Bus patterns

Prefer the golden examples for layout, naming flow, module shape, parameter minimalism, and producer-owned capabilities. Prefer current AVM metadata and Bicep diagnostics over stale example versions.

## Workflow

1. Resolve required inputs from task context: project name, environment, location, deployment scope, services, and private/public exposure intent.
2. If any required input is missing and cannot be safely inferred, stop the authoring workflow and ask concise user-facing questions before doing any Bicep authoring, metadata-dependent design, or output-file generation.
   - Ask no more than three batched questions.
   - In Plan mode, use `request_user_input` when that tool is available.
   - In Default mode or when the tool is unavailable, ask the questions directly in chat.
   - Do not replace the question step with a blocked handoff artifact unless the user explicitly asked for a written intake artifact.
3. Run `bicep --version`.
4. Resolve AVM module paths and pinned versions with `mcp__bicep__list_avm_metadata`.
5. Read the selected module documentation from metadata `documentationUri` values when parameter details are needed.
6. Author or refactor the entrypoint to match the closest golden example's shape.
7. Evaluate whether environment parameter files can be generated. Use `main.<environment>.bicepparam` naming, for example `main.dev.bicepparam`, `main.test.bicepparam`, and `main.prod.bicepparam`, only when all required parameter values are known or explicitly provided.
8. Keep module versions current by using the metadata snapshot, not the versions in the golden examples.
9. Run `mcp__bicep__get_bicep_file_diagnostics`, `bicep build <entrypoint.bicep>`, `bicep lint <entrypoint.bicep>`, and `bicep build <params-file>.bicepparam` for every generated parameter file.
10. Run `scripts/check-avm-authoring.sh <entrypoint-or-directory>`.
11. Remediate blockers and repeat checks. Stop after 2 remediation passes and report remaining blockers.

## Hard rules

- Missing-input gate: do not author files, produce a proposed Bicep skeleton, or create output artifacts before asking for missing required inputs, unless the user explicitly requested an intake artifact instead of code.
- Use direct `br/public:avm/...:<version>` module references for AVM-covered resources.
- Do not introduce local wrapper modules for AVM resources.
- Do not create native resources or sibling modules for capabilities that a selected producer AVM module can own.
- Discover producer-owned capabilities from the selected module documentation; do not rely on a fixed service-type list.
- Do not author without `projectName` and `environment` unless they are safely inferred from explicit context or an existing local convention.
- Keep parameters limited to runtime, secret, environment, and operational inputs. Put fixed design choices in variables and module properties.
- Do not create `.bicepparam` files with placeholders or fabricated values. Generate them only with real known values, explicit user-provided values, or safe non-secret defaults.
- Use managed identity by default.
- When private-only intent is present, disable public network access where supported and use producer-owned private endpoints.
- Do not create private DNS zones unless task context explicitly requests them or the golden pattern plus module documentation requires them.
- Never treat the golden example module versions as current without checking metadata.

## Handoff

Return:

- files changed
- environment parameter files generated, or omitted with missing values per environment
- AVM module paths and pinned versions used
- diagnostics/build/lint/parameter-build/checker status
- documented exceptions, if any
- unresolved blockers after remediation, if any
