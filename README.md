# Agent Skills

Agent Skills are folders of instructions, scripts, and resources that AI agents can discover and use to perform at specific tasks.

Codex uses skills to help package capabilities that teams and individuals can use to complete specific tasks in a repeatable way. This repository catalogs skills for use with Codex.

Learn more:
- [Using skills in Codex](https://developers.openai.com/codex/skills)
- [Create custom skills in Codex](https://developers.openai.com/codex/skills/create-skill)
- [Agent Skills open standard](https://agentskills.io)

## Repository layout

- `skills/.curated/`: maintained, installable skills for regular use
- `skills/.experimental/`: in-progress or trial skills (when present)
- `skills/<group>/<skill-name>/SKILL.md`: each skill's instructions, workflow, and guardrails

## Skills at a glance

| Skill | What it does | Key content |
|---|---|---|
| `bicep-avm-code` | Implements/updates Azure Bicep with AVM-first patterns and remediation loops. | Authoring contract, AVM resolution, producer-owned capabilities, remediation guidance |
| `bicep-avm-validate` | Performs validation-only review of authored Bicep and reports blockers; complements `bicep-avm-code` by acting as the validation gate. | AVM posture checks, security/naming/networking checks, same-file access rules |

## Install

Install a skill with Codex `skill-installer` from this repo path:

```text
$skill-installer install https://github.com/Hardstl/skills/tree/main/skills/.curated/bicep-avm-code
```

```text
$skill-installer install https://github.com/Hardstl/skills/tree/main/skills/.curated/bicep-avm-validate
```

If Codex is already running, restart it after installation so new skills are loaded.

## Usage notes

- Pick the skill that matches the task domain and workflow you need.
- Treat `SKILL.md` as the source of truth for behavior and guardrails.
- Keep the skills table updated as new skills are added.

## License

See each skill folder for its own `LICENSE.txt` when present.
