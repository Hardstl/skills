# Bicep Language Features and Functions

Short reference for current Bicep language features and functions, based on Microsoft Learn docs reviewed on 2026-07-01.

## Primary Sources

- [Bicep file structure and syntax](https://learn.microsoft.com/azure/azure-resource-manager/bicep/file)
- [Bicep functions overview](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Create a parameters file for Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameter-files)
- [Extendable parameter files in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-extend)
- [Imports in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-import)
- [Bicep logical operators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/operators-logical)
- [Bicep comparison operators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/operators-comparison)
- [Bicep numeric operators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/operators-numeric)
- [Bicep accessor operators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/operators-access)
- [Bicep spread operator](https://learn.microsoft.com/azure/azure-resource-manager/bicep/operator-spread)
- [Outputs in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/outputs)

## Language Features

| Feature | Short Description |
| --- | --- |
| Declarative file order | Bicep declarations can appear in any order; dependencies are inferred from symbolic references and expressions. |
| `metadata` | Stores supplementary file metadata such as description, author, or creation notes. |
| `targetScope` | Sets deployment scope: `resourceGroup`, `subscription`, `managementGroup`, or `tenant`. |
| Parameters | Runtime inputs for values that vary between deployments; can have defaults and decorators. |
| Variables | Named expressions for reusable, readable compile-time or deployment-time values. |
| Resources | Azure resources declared with symbolic names, resource type, API version, and properties. |
| Existing resources | `existing` declarations reference resources created outside the file without redeploying them. |
| Child resources | Nested or external child declarations model parent/child resource types. Prefer `parent` for external child resources. |
| Extension resources | Resources applied to another scope or resource, such as locks, role assignments, or policy assignments. |
| Modules | Reuse Bicep files or registry modules from another Bicep file; can deploy across scopes. |
| Outputs | Values returned from deployment; can use conditions, loops, decorators, and module outputs. |
| User-defined types | `type` declarations model precise object, union, array, and primitive shapes. |
| User-defined functions | `func` declarations define reusable expressions for repeated logic; docs still describe the feature as limited/experimental in places, so verify before relying on it broadly. |
| Decorators | `@description`, `@allowed`, `@secure`, and other annotations add validation and metadata. |
| Directives | `#disable-next-line`, `#disable-diagnostics`, and `#restore-diagnostics` suppress or restore diagnostics intentionally. |
| Loops | `for` expressions create repeated resources, modules, variables, properties, and outputs. |
| Conditional deployment | `if` expressions conditionally deploy resources or modules. |
| Conditions in expressions | Ternary `? :`, coalesce `??`, null-forgiving `!`, and safe-dereference `.?` shape optional values. |
| Multiline declarations | Functions, arrays, and objects can span multiple lines. |
| Comments | Supports `//` single-line and `/* ... */` multiline comments. |
| Imports | `import` brings exported variables, types, and functions from another Bicep file. |
| Exports | `@export()` exposes variables, types, or functions for import by other files. |
| Namespaces | Built-in `az` and `sys` namespaces are imported by default; use qualifiers to avoid name collisions. |
| `this` namespace | Resource-local runtime discovery functions for checking whether the current resource already exists. |
| `.bicepparam` files | Native parameter files use Bicep syntax and link to templates with `using`. |
| Multiple parameter files | Multiple `.bicepparam` files can target the same `.bicep` file with `using`; use one per deployment operation. |
| `using none` | Parameter files can opt out of binding to a Bicep file, useful for reusable base parameter layers. |
| Extendable parameter files | Bicep CLI `0.44.1+` supports `extends` and `base` to inherit and override parameters across `.bicepparam` files. |
| Nested parameter files | Chained parameter files can model global, environment, and workload-specific parameter layers. |
| Parameter file variables | `.bicepparam` files can define variables for reusable parameter expressions. |
| Parameter file types | `.bicepparam` files can define or import user-defined types. |
| Parameter file imports | `.bicepparam` files can import exported variables, types, and functions from Bicep files. |
| Parameter precedence | Template defaults are lowest, base parameter values are overridden by derived parameter files, and inline deployment arguments can override file values. |

## Decorators

| Decorator | Short Description |
| --- | --- |
| `@allowed()` | Restricts parameter values to a fixed set. |
| `@batchSize()` | Controls parallelism for looped resources or modules. |
| `@description()` | Adds Markdown-capable descriptions to declarations. |
| `@discriminator()` | Identifies the discriminator property for tagged object unions. |
| `@export()` | Makes a variable, type, or function importable by another Bicep file. |
| `@maxLength()` | Sets maximum string or array length. |
| `@maxValue()` | Sets maximum integer value. |
| `@metadata()` | Adds custom metadata to parameters, outputs, types, or functions. |
| `@minLength()` | Sets minimum string or array length. |
| `@minValue()` | Sets minimum integer value. |
| `@sealed()` | Elevates likely object property typo diagnostics to errors. |
| `@secure()` | Marks string or object parameters/types, and secure outputs in supported Bicep versions, as sensitive. |

## Function Namespaces

| Namespace | Short Description |
| --- | --- |
| `sys` | General value construction functions and decorators. |
| `az` | Azure deployment, scope, and resource helper functions. |
| `this` | Runtime resource-state functions inside a resource declaration. |

## Functions

### Any

| Function | Namespace | Short Description |
| --- | --- | --- |
| `any(value)` | `sys` | Suppresses compile-time type checking for a value; it does not transform runtime output. |

### Array

| Function | Namespace | Short Description |
| --- | --- | --- |
| `array(value)` | `sys` | Converts a value to an array. |
| `concat(array, ...)` | `sys` | Concatenates arrays. |
| `contains(container, item)` | `sys` | Checks whether an array contains a value, object contains a key, or string contains a substring. |
| `distinct(array)` | `sys` | Removes duplicate array values while preserving first occurrence order. |
| `empty(value)` | `sys` | Tests whether an array, object, string, or null value is empty. |
| `first(arrayOrString)` | `sys` | Gets the first array element or first string character. |
| `flatten(array)` | `sys` | Flattens one level of nested arrays. |
| `indexOf(array, item)` | `sys` | Finds the zero-based index of the first matching array item, or `-1`. |
| `intersection(value, ...)` | `sys` | Returns common elements or properties across arrays or objects. |
| `last(arrayOrString)` | `sys` | Gets the last array element or last string character. |
| `lastIndexOf(array, item)` | `sys` | Finds the zero-based index of the last matching array item, or `-1`. |
| `length(value)` | `sys` | Counts array elements, string characters, or root object properties. |
| `max(values)` | `sys` | Returns the largest integer from an array or argument list. |
| `min(values)` | `sys` | Returns the smallest integer from an array or argument list. |
| `range(start, count)` | `sys` | Creates an integer array from a start value and count. |
| `skip(arrayOrString, count)` | `sys` | Skips leading array elements or string characters. |
| `take(arrayOrString, count)` | `sys` | Takes leading array elements or string characters. |
| `union(value, ...)` | `sys` | Combines arrays or objects; object values are recursively merged except nested arrays. |

### CIDR

| Function | Namespace | Short Description |
| --- | --- | --- |
| `parseCidr(network)` | `sys` | Parses IPv4 or IPv6 CIDR into network, mask, usable range, and CIDR metadata. |
| `cidrSubnet(network, newCidr, subnetIndex)` | `sys` | Calculates a subnet range from a parent CIDR block. |
| `cidrHost(network, hostIndex)` | `sys` | Calculates a usable host IP address from a CIDR block. |

### Date

| Function | Namespace | Short Description |
| --- | --- | --- |
| `dateTimeAdd(base, duration, format?)` | `sys` | Adds an ISO 8601 duration to a datetime string. |
| `dateTimeFromEpoch(epoch)` | `sys` | Converts Unix epoch seconds to an ISO 8601 datetime string. |
| `dateTimeToEpoch(datetime)` | `sys` | Converts an ISO 8601 datetime string to Unix epoch seconds. |
| `utcNow(format?)` | `sys` | Returns current UTC datetime; only valid as a parameter default. |

### Deployment

| Function | Namespace | Short Description |
| --- | --- | --- |
| `deployer()` | `az` | Returns the identity that initiated the deployment. |
| `deployment()` | `az` | Returns metadata about the current deployment operation. |
| `environment()` | `az` | Returns Azure cloud environment endpoints and suffixes. |

### File

| Function | Namespace | Short Description |
| --- | --- | --- |
| `loadDirectoryFileInfo(path, pattern?)` | `sys` | Loads compile-time file metadata for matching files in a directory. |
| `loadFileAsBase64(path)` | `sys` | Embeds a file as a base64 string at compile time. |
| `loadJsonContent(path, jsonPath?, encoding?)` | `sys` | Loads JSON file content, optionally filtered by JSONPath. |
| `loadYamlContent(path, pathFilter?, encoding?)` | `sys` | Loads YAML file content, optionally filtered by path. |
| `loadTextContent(path, encoding?)` | `sys` | Loads a text file as a string. |

### Flow Control

| Function | Namespace | Short Description |
| --- | --- | --- |
| `fail(message)` | `sys` | Terminates evaluation with a custom error message inside short-circuiting expressions. |

### Lambda

| Function | Namespace | Short Description |
| --- | --- | --- |
| `filter(array, lambda)` | `sys` | Keeps array items where the lambda returns true. |
| `groupBy(array, lambda)` | `sys` | Groups array items into object properties based on a key expression. |
| `map(array, lambda)` | `sys` | Transforms each array item into a new array item. |
| `mapValues(object, lambda)` | `sys` | Transforms values of an object while preserving keys. |
| `reduce(array, initial, lambda)` | `sys` | Aggregates array items into a single value. |
| `sort(array, lambda)` | `sys` | Sorts array items using a comparison lambda. |
| `toObject(array, keyLambda, valueLambda?)` | `sys` | Converts an array to an object using generated keys and optional generated values. |

### Logical

| Function | Namespace | Short Description |
| --- | --- | --- |
| `bool(value)` | `sys` | Converts a string or integer to boolean. |

### Numeric

| Function | Namespace | Short Description |
| --- | --- | --- |
| `int(value)` | `sys` | Converts a string or integer to integer. |
| `max(values)` | `sys` | Returns the largest integer from an array or argument list. |
| `min(values)` | `sys` | Returns the smallest integer from an array or argument list. |

### Object

| Function | Namespace | Short Description |
| --- | --- | --- |
| `contains(container, item)` | `sys` | Checks object keys, array items, or string substrings. |
| `empty(value)` | `sys` | Tests whether an object, array, string, or null value is empty. |
| `intersection(value, ...)` | `sys` | Returns common properties or elements across objects or arrays. |
| `items(object)` | `sys` | Converts an object dictionary into sorted `{ key, value }` array items. |
| `json(string)` | `sys` | Parses a valid JSON string into Bicep data. |
| `length(value)` | `sys` | Counts root-level properties in an object, or length of arrays/strings. |
| `objectKeys(object)` | `sys` | Returns the root property names of an object. |
| `shallowMerge(array)` | `sys` | Merges an array of objects at the top level only. |
| `union(value, ...)` | `sys` | Combines objects with recursive object merge and later values taking precedence. |

### Parameter File

| Function | Namespace | Short Description |
| --- | --- | --- |
| `externalInput(name, config?)` | `sys` | Defers parameter value supply to an external tool at deployment initiation. |
| `getSecret(subscriptionId, resourceGroupName, keyVaultName, secretName, secretVersion?)` | `az` / default | Reads a Key Vault secret for secure parameter assignment in `.bicepparam`. |
| `readEnvironmentVariable(name, default?)` | `sys` | Reads an environment variable at compile time for `.bicepparam` values. |

### Resource

| Function | Namespace | Short Description |
| --- | --- | --- |
| `this.exists()` | `this` | Returns whether the resource in the current resource declaration already exists. |
| `this.existingResource()` | `this` | Returns the existing resource object for the current resource declaration, or null. |
| `extensionResourceId(scope, type, name...)` | `az` | Builds an extension resource ID for a scope or resource. |
| `keyVault.getSecret(secretName)` | resource accessor | Reads a Key Vault secret for a secure module parameter. |
| `resource.list*()` | resource accessor | Calls resource-provider list operations such as `listKeys`, `listSecrets`, or `listAccountSas`. |
| `managementGroupResourceId(type, name...)` | `az` | Builds a management-group-level resource ID. |
| `pickZones(provider, type, location, numberOfZones?, offset?)` | `az` | Returns supported availability zones for a zonal resource type and region. |
| `providers()` | `az` | Deprecated provider metadata lookup; use explicit API versions instead. |
| `reference(resource, apiVersion?, mode?)` | `az` | Returns runtime resource state; symbolic references or `existing` resources are usually preferred. |
| `resourceId(scope?, type, name...)` | `az` | Builds a resource ID; symbolic `.id` references are usually preferred. |
| `roleDefinitions(roleName)` | `az` | Resolves an Azure RBAC role definition by display name. |
| `subscriptionResourceId(subscriptionId?, type, name...)` | `az` | Builds a subscription-level resource ID. |
| `tenantResourceId(type, name...)` | `az` | Builds a tenant-level resource ID. |
| `toLogicalZone(subscriptionId, location, physicalZone)` | `az` | Maps a physical availability zone to a subscription-specific logical zone. |
| `toLogicalZones(subscriptionId, location, physicalZones)` | `az` | Maps multiple physical zones to logical zones. |
| `toPhysicalZone(subscriptionId, location, logicalZone)` | `az` | Maps a logical availability zone to its physical zone. |
| `toPhysicalZones(subscriptionId, location, logicalZones)` | `az` | Maps multiple logical zones to physical zones. |

### Scope

| Function | Namespace | Short Description |
| --- | --- | --- |
| `managementGroup(id?)` | `az` | Gets current management group details or returns a management group scope object. |
| `resourceGroup(name?)` | `az` | Gets current resource group details or returns a resource group scope object. |
| `resourceGroup(subscriptionId, name)` | `az` | Returns a cross-subscription resource group scope object. |
| `subscription(id?)` | `az` | Gets current subscription details or returns a subscription scope object. |
| `tenant()` | `az` | Gets tenant details or returns a tenant scope object. |

### String

| Function | Namespace | Short Description |
| --- | --- | --- |
| `base64(string)` | `sys` | Encodes a string as base64. |
| `base64ToJson(string)` | `sys` | Decodes base64 text into JSON data. |
| `base64ToString(string)` | `sys` | Decodes base64 text into a string. |
| `buildUri(components)` | `sys` | Builds a URI from scheme, host, port, path, and query components. |
| `concat(value, ...)` | `sys` | Concatenates strings or arrays; prefer string interpolation for ordinary strings. |
| `contains(container, item)` | `sys` | Checks string substring, array item, or object key existence. |
| `dataUri(string)` | `sys` | Converts a string to a data URI. |
| `dataUriToString(string)` | `sys` | Decodes a data URI to a string. |
| `empty(value)` | `sys` | Tests whether a string, array, object, or null value is empty. |
| `endsWith(string, search)` | `sys` | Case-insensitive suffix test. |
| `first(arrayOrString)` | `sys` | Gets the first string character or array element. |
| `format(formatString, value...)` | `sys` | Builds a formatted string using .NET-style composite formatting. |
| `guid(value...)` | `sys` | Generates a deterministic GUID from input strings. |
| `indexOf(string, search)` | `sys` | Finds the first zero-based substring position, case-insensitive, or `-1`. |
| `join(array, delimiter)` | `sys` | Joins a string array with a delimiter. |
| `last(arrayOrString)` | `sys` | Gets the last string character or array element. |
| `lastIndexOf(string, search)` | `sys` | Finds the last zero-based substring position, case-insensitive, or `-1`. |
| `length(value)` | `sys` | Counts string characters, array elements, or object properties. |
| `like(string, pattern)` | `sys` | Matches a string against a wildcard-style pattern. |
| `newGuid()` | `sys` | Generates a new GUID; only valid in parameter defaults. |
| `padLeft(string, totalLength, padding?)` | `sys` | Left-pads a string to a target length. |
| `parseUri(string)` | `sys` | Parses a URI into component properties. |
| `replace(string, old, new)` | `sys` | Replaces all instances of a substring. |
| `skip(arrayOrString, count)` | `sys` | Skips leading string characters or array elements. |
| `split(string, delimiter)` | `sys` | Splits a string into an array. |
| `startsWith(string, search)` | `sys` | Case-insensitive prefix test. |
| `string(value)` | `sys` | Converts a value to string, using JSON representation for non-strings. |
| `substring(string, start, length?)` | `sys` | Extracts part of a string. |
| `take(arrayOrString, count)` | `sys` | Takes leading string characters or array elements. |
| `toLower(string)` | `sys` | Converts a string to lowercase. |
| `toUpper(string)` | `sys` | Converts a string to uppercase. |
| `trim(string)` | `sys` | Removes leading and trailing whitespace. |
| `uniqueString(value...)` | `sys` | Generates a deterministic 13-character hash string from input strings. |
| `uri(baseUri, relativeUri)` | `sys` | Resolves a relative URI against a base URI. |
| `uriComponent(string)` | `sys` | URI-encodes a string. |
| `uriComponentToString(string)` | `sys` | Decodes a URI-encoded string. |

## Operators and Access Features

| Feature | Short Description |
| --- | --- |
| Property access `.` | Reads object properties, resource properties, module outputs, and imported symbols. |
| Array access `[]` | Reads an array item by index or object value by key. |
| Reverse array access `[^index]` | Reads an array item from the end; `^1` is the last item. |
| Nested resource access `::` | References a nested resource from outside its parent declaration. |
| Function accessor `.` | Calls resource-scoped functions such as `storageAccount.listKeys()`. |
| Safe dereference `.?` | Reads a property only when the left side is not null. |
| Null-forgiving `!` | Tells Bicep a nullable value is expected to be non-null. |
| Logical and `&&` | Returns true when all operands are true. |
| Logical or `||` | Returns true when at least one operand is true. |
| Logical not `!` | Negates a boolean value. |
| Coalesce `??` | Returns the first non-null value. |
| Conditional `? :` | Selects one of two values based on a condition. |
| Spread `...` | Expands object or array values into a new object or array; useful with `base` in parameter files. |
| String interpolation `${}` | Embeds expressions inside single-line strings. |
| Comparison operators | `==`, `!=`, `<`, `<=`, `>`, `>=`, `=~`, and `!~` compare values and return booleans. |
| Numeric operators | `*`, `/`, `%`, `+`, binary `-`, and unary `-` perform integer arithmetic. |

## Parameter File Notes

- Use one `.bicepparam` file per deployment operation, but create many files for environments such as `main.dev.bicepparam` and `main.prod.bicepparam`.
- `using '<file>.bicep'` binds a parameter file to a Bicep template.
- `using none` creates an unbound parameter layer, commonly used as a base file.
- `extends '<file>.bicepparam'` inherits parameter assignments from one base parameter file.
- A derived file can extend only one base file, but nested chains are supported.
- `base.<parameterName>` accesses inherited values for merging or expression building.
- Parameter files can use variables, user-defined types, imports, expressions, `getSecret`, `readEnvironmentVariable`, and `externalInput`.
