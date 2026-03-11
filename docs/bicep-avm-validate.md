# Skill Documentation: bicep-avm-validate

## Skill Overview

`bicep-avm-validate` is the validation skill for authored Azure Bicep. It reviews code against AVM-first rules and reports blockers without changing infrastructure code.

Use it when you need a validation-only gate before sign-off. Do not use it for architecture research or implementation/remediation unless the user explicitly asks to switch into authoring.

This solution is AVM all the way: validation expects direct `br/public:avm/...` usage, no local AVM wrapper modules, and no drift into sibling helper resources when producer-owned capabilities exist.

## Inputs and Preconditions

Provide the authored Bicep entrypoint and supporting files in scope.

Before validation, confirm tools are available:

- `bicep --version`
- `mcp__bicep__get_bicep_file_diagnostics`
- `bicep build`
- `bicep lint`

Validation checks only what is present in local code and task context. It does not run architecture discovery or external service-selection workflows.

## Workflow

1. Identify the environment-specific entrypoint and all relevant Bicep files.
2. Run diagnostics, `bicep build`, and `bicep lint` before semantic checks.
3. Validate AVM posture (direct AVM modules, pinned versions, no AVM-covered native resources).
4. Validate producer-owned capabilities (no sibling/standalone resources where producer parameters should be used).
5. Validate security, naming, and networking guardrails (tags, defaults, exposure, subnet/NSG posture).
6. Validate same-file compute-to-data access for Storage/Key Vault via producer-owned `roleAssignments`.
7. Report results as concrete blockers vs optional improvements, with posture status (`pass` or `blocker`) per category.

## Outputs and Handoff

The expected output is a validation report, not code changes.

Include these report details:

- Diagnostics/build/lint outcomes
- AVM posture status (`pass` or `blocker`)
- Producer-owned capability status (`pass` or `blocker`)
- Security/naming/networking status (`pass` or `blocker`)
- Same-file Storage/Key Vault access status (`pass` or `blocker`)
- File-and-behavior blockers with clear remediation direction

## Prompt Guide

Use prompts that clearly ask for validation-only behavior and identify the entrypoint.

Simple prompts:

- "Use `$bicep-avm-validate` to validate this entrypoint for AVM posture and guardrails. Do not modify code."
