# Capability Discovery

Use this reference to avoid hard-coded service-type lists. Azure has too many resource types for a static skill reference to be complete.

## Principle

For each selected AVM producer module, discover what that exact module version can own. If the module can own the requested capability through a parameter or nested parameter object, use that parameter instead of a sibling module, child resource, helper module, or native resource.

The question is not "is this one of the resource types listed in the skill?" The question is "does the selected producer module already own this capability?"

## Discovery workflow

For every selected AVM module:

1. Use the metadata snapshot to identify the module path, version, and `documentationUri`.
2. Read the module documentation when a requested capability may become a child resource, adjunct resource, or helper module.
3. Identify parameters and nested object properties that represent owned capabilities.
4. Implement supported capabilities inside the producer module.
5. Use a sibling module or native resource only when the selected module version lacks the required capability or a real scope/dependency boundary prevents producer-owned wiring.
6. Record every exception in the handoff.

## Capability signals

Treat a parameter or nested object as producer-owned when it represents any of these patterns:

- child collections owned by the resource
- private connectivity
- data-plane or management-plane access assignments
- managed identity attachment
- configuration, app settings, policies, rules, routes, or bindings
- monitoring, diagnostics, locks, role assignments, or alerts scoped to the resource
- network attachment, subnet integration, interfaces, endpoints, firewall rules, or ACLs
- nested resources whose lifecycle should follow the producer

These are capability categories, not a complete Azure type list.

## Required network posture

When a selected module exposes subnet objects with `privateEndpointNetworkPolicies`, always set:

```bicep
privateEndpointNetworkPolicies: 'Enabled'
```

Do not set it to `'Disabled'`, `'NetworkSecurityGroupEnabled'`, or `'RouteTableEnabled'` unless the user explicitly requests a different subnet policy model and the exception is documented in the handoff.

## Exception format

When a native resource or sibling module is required, leave a nearby comment in code:

```bicep
// avm-author: native-exception selected AVM module version does not expose this capability
resource specializedChild 'Microsoft.Example/examples/children@2025-01-01' = {
  name: 'example/child'
}
```

The final handoff must repeat the exception and say which metadata/doc evidence forced it.

## Fail-closed rule

If unsure whether the producer module owns a capability, check the selected module documentation before authoring a separate resource. Do not infer absence from memory or from the golden examples.
