# Anti-Patterns

Use this file as a quick negative reference before and after authoring.

## Blockers

Do not author these patterns:

- Local wrapper modules around AVM modules.
- Native resources, child resources, helper modules, or sibling AVM modules for any capability the selected producer AVM module can own.
- Standalone capability modules for access, networking, configuration, child collections, identity, diagnostics, locks, or policy when the selected producer module has first-class parameters for that capability.
- Large parameter surfaces that mirror every AVM module property.
- Explicit `dependsOn` where a module output or symbolic reference can express the dependency.
- `privateEndpointNetworkPolicies` set to any value other than `'Enabled'`.
- Private DNS zones by default when the task says DNS is centrally managed or does not mention DNS.
- Copied golden-example module versions without metadata verification.

## Suspicious shapes

Pause and verify before keeping these:

- `existing` declarations for resources that are created later in the same file.
- Non-`existing` native resources without a nearby `// avm-author: native-exception <reason>` comment.
- `dependsOn` without a nearby `// avm-author: depends-on-exception <reason>` comment.
- Outputs that expose secrets, keys, connection strings, or generated passwords.
- Public access enabled in a private-only brief.
- Subnet objects that omit `privateEndpointNetworkPolicies` when the selected AVM module type exposes the property.
- Single-principal operator access parameters such as `operatorPrincipalId` when the deployment should support more than one operations group.
- Decision-proxy parameters like `deployPrivateEndpoint`, `enableRbac`, or `useManagedIdentity` when the brief already settled the decision.
- Broad `dependsOn` arrays that compensate for avoidable dependency cycles.
- Repeated calls to module metadata or web searches after the AVM metadata snapshot already provided the needed module and documentation URI.

## Preferred replacements

- Replace local AVM wrappers with direct `br/public:avm/...:<version>` modules.
- Replace native resources and sibling modules with producer AVM parameters whenever the selected module can own the capability.
- Replace explicit `dependsOn` with module output references whenever possible.
- Replace `privateEndpointNetworkPolicies: 'Disabled'` with `privateEndpointNetworkPolicies: 'Enabled'`.
- Replace name parameters with derived names unless an external integration requires a fixed name.
- Replace connection strings and keys with managed identity and producer-owned role assignments.
- Replace post-deployment access notes with same-file role assignments when principal IDs are known.
