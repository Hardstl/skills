# Golden Implementation Plan

Use this file to track planned golden Bicep references. Keep the set small and orthogonal: each golden should teach a deployment boundary, workload shape, or AVM ownership pattern not already covered.

## Status

| Golden reference | Status | Purpose |
| --- | --- | --- |
| `golden-private-webapp-platform.bicep` | Implemented | Private Linux Web App plus Function App, VNet integration, private endpoints, managed identities, Key Vault, and hardened Storage. |
| `golden-brownfield-private-workload.bicep` | Implemented | Private Function App workload deployed into existing shared network and monitoring resources without over-creating platform infrastructure. |
| `golden-container-platform.bicep` | Implemented | Private Azure Container Apps workload with ACR, managed identity, Key Vault, observability, and no AKS resources. |
| `golden-api-integration-platform.bicep` | Planned | APIM, App Configuration, messaging, and producer-owned child collections such as APIs, policies, queues, topics, and subscriptions. |
| `golden-ai-data-platform.bicep` | Planned | Private AI/data workload with identity-first access across AI, search, storage, secrets, and data services. |

## Acceptance Criteria

- The golden teaches a reusable shape that existing examples do not already cover.
- The file follows `authoring-contract.md`, `anti-patterns.md`, and `capability-discovery.md`.
- AVM module versions are pinned and checked against current metadata before handoff.
- Producer-owned capabilities are preferred over sibling modules or native child resources.
- `bicep build`, `bicep lint`, and `scripts/check-avm-authoring.sh` pass or blockers are documented.

## Notes

- Prefer refreshing or replacing old examples when a new golden supersedes them.
- Keep service variety secondary to shape coverage; the AVM catalog remains the source of breadth.
- Do not add private DNS zones to goldens unless the scenario explicitly teaches DNS ownership.
