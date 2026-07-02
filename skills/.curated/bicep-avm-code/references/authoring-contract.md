# Authoring Contract

Use this contract for every Bicep file authored with `bicep-avm-code`.

## Source of truth order

1. Explicit user request, design brief, or structured handoff artifact
2. AVM metadata snapshot from `mcp__bicep__list_avm_metadata`
3. Selected AVM module documentation from metadata `documentationUri`
4. Bicep diagnostics, build, and lint
5. Golden examples in this skill
6. This contract

The golden examples teach shape. They are not proof that a copied module version or parameter is current.

## Input intake

Before authoring, resolve these required inputs:

- project name
- environment
- location
- deployment scope
- requested services
- private/public exposure intent

Infer an input only when it is explicit in the task, an existing Bicep parameter, an existing naming convention, or a nearby parameter file. Otherwise ask the user concise questions before authoring.

This is a hard gate. When any required input is missing:

- stop before creating or editing Bicep files
- do not run ahead into module selection, placeholder templates, or output artifacts
- ask the user for the missing values as the next user-visible action
- use `request_user_input` when running in Plan mode and the tool is available
- ask directly in chat when `request_user_input` is unavailable
- only write an intake or blocked-status artifact if the user explicitly requested that artifact instead of immediate questions

Use at most three questions in one message. Batch related missing inputs together, for example:

- "What `projectName` and `environment` should this deployment use?"
- "Which Azure region and deployment scope should I target?"
- "Should this be private-only or allow public access?"

Do not invent `projectName`, `environment`, or exposure posture from the repository name alone.

## Entrypoint shape

Use this order unless the existing codebase has a stronger local convention:

1. `targetScope`
2. parameters
3. variables for names, tags, role definition IDs, and derived resource IDs
4. optional `existing` resources
5. AVM modules in dependency order
6. outputs

## Dependency shape

Prefer symbolic references and module outputs over explicit `dependsOn`.

- Pass producer module outputs into consumer module parameters when the producer must exist first.
- Use AVM outputs such as resource IDs, subnet IDs, principal IDs, and endpoint IDs to express deployment order.
- Avoid derived `resourceId()` strings when a same-file module output is available.
- Do not add `dependsOn` unless no value can flow between modules and a real deployment-order constraint remains.
- If explicit `dependsOn` is required, add a nearby `// avm-author: depends-on-exception <reason>` comment and repeat the exception in the handoff.

## Required baseline parameters

Use these unless task context provides a stricter interface:

```bicep
@description('Azure region for all regional resources.')
param location string = resourceGroup().location

@description('Short project name used for resource names and tags.')
param projectName string

@description('Deployment environment name, such as dev, test, qa, or prod.')
param environment string
```

Add parameters only for values the operator should decide at deployment time: CIDRs, SKU choices, existing subnet IDs, secrets, principal IDs, allowed IP ranges, feature toggles, and capacity settings.

## Environment parameter files

When authoring a new entrypoint, evaluate whether environment `.bicepparam` files can be generated for the deployment.

Use the naming pattern `main.<environment>.bicepparam` for a `main.bicep` entrypoint, for example:

```bicep
using './main.bicep'
```

Prefer these standard environment files when the task context supports them:

- `main.dev.bicepparam`
- `main.test.bicepparam`
- `main.prod.bicepparam`

Generate a parameter file only when every required parameter assignment in that file can use one of these value sources:

- an explicit user-provided value
- an existing local convention or nearby parameter file value
- a safe non-secret default that already belongs in the deployment contract

Do not fabricate or placeholder values for subnet IDs, resource IDs, tenant IDs, principal IDs, Entra group object IDs, principal names, secrets, model deployments, production IP ranges, or production capacity settings. Do not emit broken skeleton parameter files.

For every generated `.bicepparam` file, run:

```bash
bicep build <params-file>.bicepparam
```

If one or more environment parameter files cannot be generated, do not create placeholders. Report the omitted files in the final handoff and list the missing values for each environment.

## Naming and tags

Prefer derived names over name parameters.

```bicep
var nameToken = toLower(replace('${projectName}-${environment}', '_', '-'))

var tags = {
  project: projectName
  environment: environment
  managedBy: 'bicep'
}
```

Use service-specific abbreviations only when needed to satisfy name rules.

## AVM module rules

- Use direct registry references: `br/public:avm/res/<provider>/<resource>:<version>`.
- Pin versions from the metadata snapshot.
- Do not use local wrapper modules for AVM-covered resources.
- Do not use native resources or sibling modules for capabilities that a selected AVM producer module can own.
- Record any native-resource exception in the final handoff with the reason.

## Producer-owned capability rules

Prefer producer-owned module parameters over sibling resources, child resources, helper modules, or native extension resources.

Discover producer-owned capabilities from the selected module documentation, not from a fixed list of Azure resource types. Read `capability-discovery.md` before deciding that a separate native resource, child resource, helper module, or sibling AVM module is necessary.

If a selected module lacks a required capability, document the exception and use the narrowest native resource, child resource, helper module, or sibling module needed.

## Same-file access

When the same file creates both a managed-identity consumer and a data producer, grant required data-plane access in that same file through the producer module's `roleAssignments` when principal IDs are known at authoring time.

For human operational access, add producer-owned role assignments inline for `deployer().objectId` on resources that a deployer normally needs to use after deployment. Infer the principal type with `empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'`.

Examples include Key Vault Secrets User on deployed Key Vaults, Storage Blob Data Contributor on deployed Storage accounts, and service-specific data-plane roles required for smoke testing. Keep these role assignments close to the resource module instead of hiding them behind shared operations variables.

When a user explicitly asks for additional operational principals, use a typed `operationsPrincipals` array that accepts `User`, `Group`, and `ServicePrincipal`. Do not make group-only access the primary golden path, and do not add `operationsGroupObjectIds`.

Allow deferral only when there is a real dependency cycle, runtime-only principal ID, or cross-scope boundary that the producer module cannot own.

## Private exposure intent

Treat these words as private-only intent unless the user says otherwise: `private`, `corp`, `internal`, `no public access`, `locked down`.

For private-only intent:

- disable public network access where the module supports it
- use producer-owned `privateEndpoints`
- use existing private endpoint subnet IDs or VNet/subnet modules from the same file
- do not create private DNS zones unless requested or required by the task context

## Network posture

Set `privateEndpointNetworkPolicies: 'Enabled'` on every authored subnet object that exposes the property.

- Treat `privateEndpointNetworkPolicies: 'Disabled'` as a blocker.
- Do not omit `privateEndpointNetworkPolicies` when authoring a subnet object whose type supports it.
- Do not parameterize this value unless the user explicitly asks for a different subnet policy model.
- If an existing codebase or Azure constraint requires another value, document the exception in the handoff.

## Completion bar

Before handoff:

1. Resolve module paths and versions.
2. Check the closest golden example for layout and pattern shape.
3. Discover producer-owned capabilities for each selected module.
4. Evaluate whether `main.<environment>.bicepparam` files can be generated from known values.
5. Run diagnostics.
6. Run `bicep build`.
7. Run `bicep lint`.
8. Run `bicep build <params-file>.bicepparam` for every generated parameter file.
9. Run `scripts/check-avm-authoring.sh`.
10. Fix blockers or report exactly why they remain, including omitted parameter files and missing values per environment.
